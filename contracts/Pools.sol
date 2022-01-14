// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Token.sol";

contract Pools is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private traunchId;

    event ClaimComplete(
        uint256 indexed _traunchId,
        address indexed _account,
        uint256 indexed _amount
    );

    event ClaimProjectTokens(
        uint256 indexed _traunchId,
        address indexed _account,
        uint256 indexed _amount
    );

    event ClaimOldProjectTokens(
        address indexed _account,
        uint256 indexed _amount
    );

    event Refund(
        uint256 indexed _traunchId,
        address indexed _account,
        uint256 indexed _amount
    );

    event OldRefunds(address indexed _account, uint256 indexed _amount);

    event ExecutorChanged(address oldExecutor, address newExecutor);

    event GoalReached(
        uint256 indexed _traunchId,
        address indexed _account,
        address indexed _projectToken,
        uint256 _goal
    );

    event NewTraunch(
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

    struct Traunch {
        uint256 traunchId;
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
    mapping(uint256 => Traunch) public traunches;

    bool public newPool;
    string public name;

    address public executor;

    constructor(
        address _projectToken,
        address _tradeToken,
        string memory _name
    ) {
        projectToken = Token(_projectToken);
        tradeToken = ERC20(_tradeToken);
        newPool = true;
        name = _name;
    }

    modifier isAuthorized() {
        require(
            msg.sender == owner() || msg.sender == executor,
            "Pools: unauthorized"
        );
        _;
    }

    function createNewTraunch(
        uint256 _totalTokenAmount,
        uint256 _startingTime,
        uint256 _goal,
        uint256 _cap
    ) external onlyOwner {
        uint256 currentTraunch = getCurrentTraunch();
        if (currentTraunch != 0) {
            require(
                hasGoalReached(currentTraunch) || hasPoolEnded(currentTraunch),
                "Pools: active traunch"
            );
        }

        require(
            _goal <= _totalTokenAmount,
            "Pools: Goal cannot be more than TotalTokenAmount"
        );

        require(projectToken.owner() == address(this), "Pools: not owner");

        require(_cap <= _goal, "Pools: cap per user cannot be more than goal");

        traunchId.increment();

        Traunch memory traunch = Traunch(
            traunchId.current(),
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

        traunches[traunchId.current()] = traunch;

        emit NewTraunch(_totalTokenAmount, _startingTime, _goal, _cap);
    }

    function purchaseProjectTokens(uint256 _amount) external {
        uint256 _traunchId = getCurrentTraunch();
        Traunch memory traunch = traunches[_traunchId];

        require(traunch.active, "Pools: inactive traunch");
        require(block.timestamp >= traunch.startTime, "Pools: Not yet opened");
        require(block.timestamp < traunch.endTime, "Pools: Closed");

        require(
            SafeMath.add(traunch.totalCollectedWei, _amount) <= traunch.goal,
            "Pools: goal exceeded"
        );

        require(
            tradeToken.balanceOf(msg.sender) >= _amount && _amount != 0,
            "Pools: Insufficient trade token"
        );

        uint256 traunchCap = traunch.capacity;
        if (traunchCap != 0) {
            require(
                SafeMath.add(
                    investors[_traunchId][msg.sender].investment,
                    _amount
                ) <= traunchCap,
                "Pools: Cap exceeded"
            );
        }

        if (investors[_traunchId][msg.sender].investment == 0) {
            registerInvestor(msg.sender, _amount, _traunchId);
        } else {
            investors[_traunchId][msg.sender].investment = SafeMath.add(
                investors[_traunchId][msg.sender].investment,
                _amount
            );

            investors[_traunchId][msg.sender].tokensOwn = calcTokens(
                SafeMath.sub(
                    investors[_traunchId][msg.sender].investment,
                    investors[_traunchId][msg.sender].tokensClaimed
                ),
                _traunchId
            );
        }

        tradeToken.transferFrom(msg.sender, address(this), _amount);

        traunches[_traunchId].totalCollectedWei = SafeMath.add(
            traunches[_traunchId].totalCollectedWei,
            _amount
        );

        _goalReached(_traunchId);
    }

    function claimTokens() external {
        uint256 amount = 0;
        for (uint256 i = 1; i < getCurrentTraunch(); i++) {
            uint256 tokens = investors[i][msg.sender].tokensOwn;
            investors[i][msg.sender].tokensOwn = 0;
            amount = SafeMath.add(tokens, amount);
        }

        projectToken.mint(msg.sender, amount);
        emit ClaimOldProjectTokens(msg.sender, amount);
    }

    function claimTokens(uint256 _traunchId) external {
        require(hasGoalReached(_traunchId), "Pools: goal not reached");

        uint256 tokens = investors[_traunchId][msg.sender].tokensOwn;
        require(tokens > 0, "Pools: zero tokens to claim");

        investors[_traunchId][msg.sender].tokensOwn = 0; // make sure this goes first before transfer to prevent reentrancy
        investors[_traunchId][msg.sender].tokensClaimed = tokens;
        traunches[_traunchId].totalClaims = SafeMath.add(
            traunches[_traunchId].totalClaims,
            tokens
        );

        projectToken.mint(msg.sender, tokens);

        emit ClaimProjectTokens(_traunchId, msg.sender, tokens);

        if (traunches[_traunchId].goal == traunches[_traunchId].totalClaims)
            emit ClaimComplete(_traunchId, msg.sender, tokens);
    }

    function getRefund() external {
        uint256 amount = 0;
        for (uint256 i = 1; i < getCurrentTraunch(); i++) {
            uint256 refundAmount = investors[i][msg.sender].investment;
            investors[i][msg.sender].investment = 0;
            investors[i][msg.sender].tokensOwn = 0;
            amount = SafeMath.add(refundAmount, amount);
        }

        _getRefund(amount);
        emit OldRefunds(msg.sender, amount);
    }

    function getRefund(uint256 _traunchId) external {
        require(hasPoolEnded(_traunchId), "Pools: not ended yet");
        require(!hasGoalReached(_traunchId), "Pools: goal reached");
        require(
            investors[_traunchId][msg.sender].investment > 0,
            "Pools: zero investment"
        );

        uint256 refundAmount = investors[_traunchId][msg.sender].investment;
        require(refundAmount > 0, "Pools: zero refunds");

        investors[_traunchId][msg.sender].investment = 0; // make sure this goes first before transfer to prevent reentrancy
        investors[_traunchId][msg.sender].tokensOwn = 0;

        _getRefund(refundAmount);
        emit Refund(_traunchId, msg.sender, refundAmount);
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
        uint256 _traunchId
    ) internal {
        uint256 tokens = calcTokens(_amount, _traunchId);

        investors[_traunchId][_sender] = Investor(
            _amount,
            tokens,
            block.timestamp,
            0
        );

        traunches[_traunchId].totalInvestors = SafeMath.add(
            traunches[_traunchId].totalInvestors,
            1
        );
    }

    function calcTokens(uint256 _amount, uint256 _traunchId)
        internal
        view
        returns (uint256)
    {
        uint256 ratio = SafeMath.div(
            traunches[_traunchId].totalTokenAmount,
            traunches[_traunchId].goal
        );
        uint256 result = SafeMath.mul(_amount, ratio);

        return result;
    }

    function updatePoolEndTime(uint256 _poolEndTime, uint256 _traunchId)
        public
        isAuthorized
    {
        require(!hasGoalReached(_traunchId), "Pools: inactive pool");
        traunches[_traunchId].endTime = _poolEndTime;
    }

    function updateCapPerUser(uint256 _cap, uint256 _traunchId)
        public
        isAuthorized
    {
        require(
            SafeMath.add(traunches[_traunchId].capacity, _cap) <=
                traunches[_traunchId].goal,
            "Pools: cap > goal"
        );

        traunches[_traunchId].capacity = _cap;
    }

    function mintProjectTokens(address _account, uint256 _amount)
        public
        isAuthorized
    {
        projectToken.mint(_account, _amount);
    }

    function withdrawTradeTokens(uint256 _traunchId) external onlyOwner {
        require(hasGoalReached(_traunchId), "Pools: cannot withdraw");
        uint256 balance = tradeToken.balanceOf(address(this));

        require(balance >= 0, "Pools: balance of pool is zero");
        tradeToken.transfer(msg.sender, balance);
    }

    function hasPoolEnded(uint256 _traunchId) public view returns (bool) {
        if (block.timestamp > traunches[_traunchId].endTime) return true;
        else return false;
    }

    function hasGoalReached(uint256 _traunchId) public view returns (bool) {
        return traunches[_traunchId].goalReached;
    }

    function _goalReached(uint256 _traunchId) internal {
        if (hasGoalReached(_traunchId)) {
            traunches[_traunchId].active = false;
            traunches[_traunchId].goalReached = true;
            emit GoalReached(
                _traunchId,
                msg.sender,
                address(projectToken),
                traunches[_traunchId].goal
            );
        }
    }

    function _setExecutor(address _newExecutor) external onlyOwner {
        address oldExecutor = executor;
        executor = _newExecutor;
        emit ExecutorChanged(oldExecutor, _newExecutor);
    }

    function getCurrentTraunch() public view returns (uint256) {
        return traunchId.current();
    }
}
