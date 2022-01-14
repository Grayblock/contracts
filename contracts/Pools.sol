// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Token.sol";

contract Pools is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private tranchId;

    event ClaimComplete(
        uint256 indexed _tranchId,
        address indexed _account,
        uint256 indexed _amount
    );

    event ClaimProjectTokens(
        uint256 indexed _tranchId,
        address indexed _account,
        uint256 indexed _amount
    );

    event ClaimOldProjectTokens(
        address indexed _account,
        uint256 indexed _amount
    );

    event Refund(
        uint256 indexed _tranchId,
        address indexed _account,
        uint256 indexed _amount
    );

    event OldRefunds(address indexed _account, uint256 indexed _amount);

    event ExecutorChanged(address oldExecutor, address newExecutor);

    event GoalReached(
        uint256 indexed _tranchId,
        address indexed _account,
        address indexed _projectToken,
        uint256 _goal
    );

    event NewTranch(
        uint256 totalTokenAmount,
        uint256 startingTime,
        uint256 goal,
        uint256 cap
    );

    Token public projectToken;
    ERC20 public tradeToken;

    struct Investor {
        uint256 investment; //the amount of the main coin invested, calc with rate
        uint256 tokensOwn; //the amount of Tokens the investor need to get from the contract
        uint256 investTime; //the time that investment made
        uint256 tokensClaimed;
    }

    struct Tranch {
        uint256 tranchId;
        uint256 goal;
        uint256 capacity;
        uint256 startTime;
        uint256 endTime;
        uint256 totalTokenAmount;
        uint256 totalInvestors;
        uint256 totalCollectedWei;
        bool active;
        bool goalReached;
        uint256 totalClaims;
    }

    mapping(uint256 => mapping(address => Investor)) public investors;
    mapping(uint256 => Tranch) public tranches;

    string public name;

    address public executor;

    constructor(
        address _projectToken,
        address _tradeToken,
        string memory _name
    ) {
        projectToken = Token(_projectToken);
        tradeToken = ERC20(_tradeToken);
        name = _name;
    }

    modifier isAuthorized() {
        require(
            msg.sender == owner() || msg.sender == executor,
            "Pools: unauthorized"
        );
        _;
    }

    function createNewTranch(
        uint256 _totalTokenAmount,
        uint256 _startingTime,
        uint256 _goal,
        uint256 _cap
    ) external onlyOwner {
        uint256 currentTranch = getCurrentTranch();
        if (currentTranch != 0) {
            require(
                hasGoalReached(currentTranch) || hasPoolEnded(currentTranch),
                "Pools: active tranch"
            );
        }

        require(
            _goal <= _totalTokenAmount,
            "Pools: Goal cannot be more than TotalTokenAmount"
        );

        require(projectToken.owner() == address(this), "Pools: not owner");

        require(_cap <= _goal, "Pools: cap per user cannot be more than goal");

        tranchId.increment();

        Tranch memory tranch = Tranch(
            tranchId.current(),
            _goal,
            _cap,
            _startingTime,
            _startingTime + (86400 * 7),
            _totalTokenAmount,
            0,
            0,
            true,
            false,
            0
        );

        tranches[tranchId.current()] = tranch;

        emit NewTranch(_totalTokenAmount, _startingTime, _goal, _cap);
    }

    function purchaseProjectTokens(uint256 _amount) external {
        uint256 _tranchId = getCurrentTranch();
        Tranch memory tranch = tranches[_tranchId];

        require(tranch.active, "Pools: inactive tranch");
        require(block.timestamp >= tranch.startTime, "Pools: Not yet opened");
        require(block.timestamp < tranch.endTime, "Pools: Closed");

        require(
            SafeMath.add(tranch.totalCollectedWei, _amount) <= tranch.goal,
            "Pools: goal exceeded"
        );

        require(
            tradeToken.balanceOf(msg.sender) >= _amount && _amount != 0,
            "Pools: Insufficient trade token"
        );

        uint256 tranchCap = tranch.capacity;
        if (tranchCap != 0) {
            require(
                SafeMath.add(
                    investors[_tranchId][msg.sender].investment,
                    _amount
                ) <= tranchCap,
                "Pools: Cap exceeded"
            );
        }

        if (investors[_tranchId][msg.sender].investment == 0) {
            registerInvestor(msg.sender, _amount, _tranchId);
        } else {
            investors[_tranchId][msg.sender].investment = SafeMath.add(
                investors[_tranchId][msg.sender].investment,
                _amount
            );

            investors[_tranchId][msg.sender].tokensOwn = calcTokens(
                SafeMath.sub(
                    investors[_tranchId][msg.sender].investment,
                    investors[_tranchId][msg.sender].tokensClaimed
                ),
                _tranchId
            );
        }

        tradeToken.transferFrom(msg.sender, address(this), _amount);

        tranches[_tranchId].totalCollectedWei = SafeMath.add(
            tranches[_tranchId].totalCollectedWei,
            _amount
        );

        _goalReached(_tranchId);
    }

    function claimTokens() external {
        uint256 amount = 0;
        for (uint256 i = 1; i < getCurrentTranch(); i++) {
            uint256 tokens = investors[i][msg.sender].tokensOwn;
            if (tokens == 0) {
                continue;
            }

            investors[i][msg.sender].tokensOwn = 0;
            amount = SafeMath.add(tokens, amount);
        }

        projectToken.mint(msg.sender, amount);
        emit ClaimOldProjectTokens(msg.sender, amount);
    }

    function claimTokens(uint256 _tranchId) external {
        require(hasGoalReached(_tranchId), "Pools: goal not reached");

        uint256 tokens = investors[_tranchId][msg.sender].tokensOwn;
        require(tokens > 0, "Pools: zero tokens to claim");

        investors[_tranchId][msg.sender].tokensOwn = 0; // make sure this goes first before transfer to prevent reentrancy
        investors[_tranchId][msg.sender].tokensClaimed = tokens;
        tranches[_tranchId].totalClaims = SafeMath.add(
            tranches[_tranchId].totalClaims,
            tokens
        );

        projectToken.mint(msg.sender, tokens);

        emit ClaimProjectTokens(_tranchId, msg.sender, tokens);

        if (tranches[_tranchId].goal == tranches[_tranchId].totalClaims)
            emit ClaimComplete(_tranchId, msg.sender, tokens);
    }

    function getRefund() external {
        uint256 amount = 0;
        for (uint256 i = 1; i < getCurrentTranch(); i++) {
            uint256 refundAmount = investors[i][msg.sender].investment;
            if (refundAmount == 0) {
                continue;
            }

            investors[i][msg.sender].investment = 0;
            investors[i][msg.sender].tokensOwn = 0;
            amount = SafeMath.add(refundAmount, amount);
        }

        _getRefund(amount);
        emit OldRefunds(msg.sender, amount);
    }

    function getRefund(uint256 _tranchId) external {
        require(hasPoolEnded(_tranchId), "Pools: not ended yet");
        require(!hasGoalReached(_tranchId), "Pools: goal reached");
        require(
            investors[_tranchId][msg.sender].investment > 0,
            "Pools: zero investment"
        );

        uint256 refundAmount = investors[_tranchId][msg.sender].investment;
        require(refundAmount > 0, "Pools: zero refunds");

        investors[_tranchId][msg.sender].investment = 0; // make sure this goes first before transfer to prevent reentrancy
        investors[_tranchId][msg.sender].tokensOwn = 0;

        _getRefund(refundAmount);
        emit Refund(_tranchId, msg.sender, refundAmount);
    }

    function _getRefund(uint256 _refundAmount) internal {
        uint256 poolBalance = tradeToken.balanceOf(address(this));
        require(
            poolBalance > 0 && poolBalance > _refundAmount,
            "Pools: insufficient trade token"
        );

        tradeToken.transfer(msg.sender, _refundAmount);
    }

    function registerInvestor(
        address _sender,
        uint256 _amount,
        uint256 _tranchId
    ) internal {
        uint256 tokens = calcTokens(_amount, _tranchId);

        investors[_tranchId][_sender] = Investor(
            _amount,
            tokens,
            block.timestamp,
            0
        );

        tranches[_tranchId].totalInvestors = SafeMath.add(
            tranches[_tranchId].totalInvestors,
            1
        );
    }

    function calcTokens(uint256 _amount, uint256 _tranchId)
        internal
        view
        returns (uint256)
    {
        uint256 ratio = SafeMath.div(
            tranches[_tranchId].totalTokenAmount,
            tranches[_tranchId].goal
        );
        uint256 result = SafeMath.mul(_amount, ratio);

        return result;
    }

    function updatePoolEndTime(uint256 _poolEndTime, uint256 _tranchId)
        public
        isAuthorized
    {
        require(!hasGoalReached(_tranchId), "Pools: inactive pool");
        tranches[_tranchId].endTime = _poolEndTime;
    }

    function updateCapPerUser(uint256 _cap, uint256 _tranchId)
        public
        isAuthorized
    {
        require(
            SafeMath.add(tranches[_tranchId].capacity, _cap) <=
                tranches[_tranchId].goal,
            "Pools: cap > goal"
        );

        tranches[_tranchId].capacity = _cap;
    }

    function mintProjectTokens(address _account, uint256 _amount)
        public
        isAuthorized
    {
        projectToken.mint(_account, _amount);
    }

    function withdrawTradeTokens(uint256 _tranchId) external onlyOwner {
        require(hasGoalReached(_tranchId), "Pools: cannot withdraw");
        uint256 balance = tradeToken.balanceOf(address(this));

        require(balance >= 0, "Pools: balance of pool is zero");
        tradeToken.transfer(msg.sender, balance);
    }

    function hasPoolEnded(uint256 _tranchId) public view returns (bool) {
        if (block.timestamp > tranches[_tranchId].endTime) return true;
        else return false;
    }

    function hasGoalReached(uint256 _tranchId) public view returns (bool) {
        return tranches[_tranchId].goalReached;
    }

    function _goalReached(uint256 _tranchId) internal {
        if (hasGoalReached(_tranchId)) {
            tranches[_tranchId].active = false;
            tranches[_tranchId].goalReached = true;
            emit GoalReached(
                _tranchId,
                msg.sender,
                address(projectToken),
                tranches[_tranchId].goal
            );
        }
    }

    function _setExecutor(address _newExecutor) external onlyOwner {
        address oldExecutor = executor;
        executor = _newExecutor;
        emit ExecutorChanged(oldExecutor, _newExecutor);
    }

    function getCurrentTranch() public view returns (uint256) {
        return tranchId.current();
    }
}
