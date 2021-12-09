// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Token.sol";

contract Pools is Ownable {
    event FinishPool();
    event PoolUpdate();

    event TransferOut(uint256 Amount, address To, address Token);
    event TransferIn(uint256 Amount, address From, address Token);
    event GoalReached(
        uint256 indexed _goal,
        address indexed _account,
        address indexed _projectToken
    );

    uint256 public Goal;
    uint256 public Cap;
    uint256 public LeftTokens; // the ammount of tokens left for sale
    uint256 public PoolStartTime; //Until what time the pool is active
    uint256 public PoolEndTime; //Until what time the pool is active
    uint256 public TotalTokenAmount; //The total amount of the tokens for sale
    uint256 public TotalInvestors; // total number of investors in a particular pool
    uint256 public TotalCollectedWei;

    Token public projectToken;
    Token public tradeToken;

    struct Investor {
        uint256 Investment; //the amount of the main coin invested, calc with rate
        uint256 TokensOwn; //the amount of Tokens the investor needto get from the contract
        uint256 InvestTime; //the time that investment made
        uint256 TokensClaimed;
    }

    mapping(address => Investor) public Investors;
    bool public newPool;

    constructor(address _projectToken, address _tradeToken) {
        projectToken = Token(_projectToken);
        tradeToken = Token(_tradeToken);
        newPool = true;
    }

    modifier TestAllownce(
        address _token,
        address _owner,
        uint256 _amount
    ) {
        require(
            IERC20(_token).allowance(_owner, address(this)) >= _amount,
            "no allowance"
        );
        _;
    }

    modifier investorOnly() {
        require(Investors[msg.sender].Investment > 0, "Not an investor");
        _;
    }

    function CheckBalance(address _Token, address _Subject)
        internal
        view
        returns (uint256)
    {
        return IERC20(_Token).balanceOf(_Subject);
    }

    function TransferInToken(
        address _Token,
        address _Subject,
        uint256 _Amount
    ) internal TestAllownce(_Token, _Subject, _Amount) {
        require(_Amount > 0);
        uint256 OldBalance = CheckBalance(_Token, address(this));
        IERC20(_Token).transferFrom(_Subject, address(this), _Amount);
        emit TransferIn(_Amount, _Subject, _Token);
        require(
            (SafeMath.add(OldBalance, _Amount)) ==
                CheckBalance(_Token, address(this)),
            "recive wrong amount of tokens"
        );
    }

    //create a new pool
    function CreatePool(
        uint256 _TotalTokenAmount, //Total amount of the tokens to sell in the pool
        uint256 _StartingTime, //Until what time the pool will work
        uint256 _goal,
        uint256 _cap
    ) external onlyOwner {
        require(
            _goal <= _TotalTokenAmount,
            "Goal cannot be more than TotalTokenAmount"
        );
        require(_cap <= _goal, "Cap per user cannot be more than goal");
        require(projectToken.owner() == address(this), "Pools: not owner");

        // TransferInToken(address(projectToken), msg.sender, _TotalTokenAmount);

        PoolStartTime = _StartingTime;
        PoolEndTime = _StartingTime + (86400 * 7);

        if (newPool) {
            Goal = _goal;
            Cap = _cap;
            TotalTokenAmount = _TotalTokenAmount;
            LeftTokens = _TotalTokenAmount;
            newPool = false;
        } else {
            Goal = SafeMath.add(Goal, _goal);
            Cap = SafeMath.add(Cap, _cap);
            TotalTokenAmount = SafeMath.add(
                TotalTokenAmount,
                _TotalTokenAmount
            );
            LeftTokens = SafeMath.add(LeftTokens, _TotalTokenAmount);
        }
    }

    function Invest(uint256 _amount) external {
        require(block.timestamp >= PoolStartTime, "Not yet opened");
        require(block.timestamp < PoolEndTime, "Closed");
        require(
            SafeMath.add(TotalCollectedWei, _amount) <= Goal,
            "Goal reached"
        );
        require(
            tradeToken.balanceOf(msg.sender) >= _amount && _amount != 0,
            "Insufficient TBUSD"
        );
        if (Cap != 0) {
            require(
                SafeMath.add(Investors[msg.sender].Investment, _amount) <= Cap,
                "Cap exceeded"
            );
        }

        if (Investors[msg.sender].Investment == 0) {
            RegisterInvestor(msg.sender, _amount);
        } else {
            Investors[msg.sender].Investment = SafeMath.add(
                Investors[msg.sender].Investment,
                _amount
            );

            Investors[msg.sender].TokensOwn = CalcTokens(
                SafeMath.sub(
                    Investors[msg.sender].Investment,
                    Investors[msg.sender].TokensClaimed
                )
            );
        }

        tradeToken.transferFrom(msg.sender, address(this), _amount);

        TotalCollectedWei = SafeMath.add(TotalCollectedWei, _amount);
        _goalReached();
    }

    function claimTokens() external investorOnly {
        require(hasGoalReached(), "Pool has failed");
        uint256 tokens = Investors[msg.sender].TokensOwn;
        require(tokens > 0, "Zero tokens to claim");

        Investors[msg.sender].TokensOwn = 0; // make sure this goes first before transfer to prevent reentrancy
        Investors[msg.sender].TokensClaimed = tokens;

        projectToken.mint(msg.sender, tokens);

        emit TransferOut(tokens, msg.sender, address(projectToken));
        RegisterClaim(tokens);
    }

    function getRefund() external {
        require(hasPoolEnded(), "Pool has not ended yet");
        require(!hasGoalReached(), "Pool successful");
        require(Investors[msg.sender].Investment > 0, "Zero investment");

        uint256 refundAmount = SafeMath.sub(
            Investors[msg.sender].Investment,
            Investors[msg.sender].TokensClaimed
        );
        require(refundAmount > 0, "Zero refunds");

        Investors[msg.sender].Investment = 0; // make sure this goes first before transfer to prevent reentrancy
        Investors[msg.sender].TokensOwn = 0;

        uint256 poolBalance = tradeToken.balanceOf(address(this));
        require(poolBalance > 0, "Balance of pool is zero");

        if (refundAmount > poolBalance) {
            refundAmount = poolBalance;
        }

        tradeToken.transfer(msg.sender, refundAmount);
        emit TransferOut(refundAmount, msg.sender, address(tradeToken));
    }

    function RegisterClaim(uint256 _Tokens) internal {
        require(_Tokens <= LeftTokens, "Not enough tokens in the pool");
        LeftTokens = SafeMath.sub(LeftTokens, _Tokens);
        if (LeftTokens == 0) emit FinishPool();
        else emit PoolUpdate();
    }

    function RegisterInvestor(address _Sender, uint256 _Amount)
        internal
        returns (uint256)
    {
        uint256 Tokens = CalcTokens(_Amount);

        Investors[_Sender] = Investor(_Amount, Tokens, block.timestamp, 0);

        TotalInvestors = SafeMath.add(TotalInvestors, 1);
        return SafeMath.sub(TotalInvestors, 1);
    }

    function CalcTokens(uint256 _Amount) internal view returns (uint256) {
        uint256 ratio = SafeMath.div(TotalTokenAmount, Goal);
        uint256 result = SafeMath.mul(_Amount, ratio);

        return result;
    }

    function updatePoolEndTime(uint256 _poolEndTime) public onlyOwner {
        PoolEndTime = _poolEndTime;
    }

    function updateCapPerUser(uint256 _cap) public onlyOwner {
        Cap = _cap;
    }

    function mintProjectTokens(address _account, uint256 _amount)
        public
        onlyOwner
    {
        projectToken.mint(_account, _amount);
    }

    function withdrawTradeTokens() public onlyOwner {
        require(hasPoolEnded(), "Pool has not ended yet");
        uint256 balance = tradeToken.balanceOf(address(this));
        require(balance >= 0, "Balance of pool is zero");
        tradeToken.transfer(msg.sender, balance);
    }

    function hasPoolEnded() public view returns (bool) {
        if (block.timestamp > PoolEndTime) return true;
        else return false;
    }

    function hasGoalReached() public view returns (bool) {
        if (tradeToken.balanceOf(address(this)) >= Goal) return true;
        else return false;
    }

    function _goalReached() internal {
        if (hasGoalReached()) {
            emit GoalReached(Goal, msg.sender, address(projectToken));
        }
    }
}
