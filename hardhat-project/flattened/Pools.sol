// Sources flattened with hardhat v2.6.4 https://hardhat.org

// File @openzeppelin/contracts/GSN/Context.sol@v3.0.2

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v3.0.2


pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File @openzeppelin/contracts/math/SafeMath.sol@v3.0.2


pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v3.0.2


pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/Pools.sol


pragma solidity ^0.6.12;

contract Pools is Ownable {
    event FinishPool();
    event PoolUpdate();

    event TransferOut(uint256 Amount, address To, address Token);
    event TransferIn(uint256 Amount, address From, address Token);

    uint256 public Goal;
    uint256 public Cap;
    uint256 public LeftTokens; // the ammount of tokens left for sale
    uint256 public PoolStartTime; //Until what time the pool is active
    uint256 public PoolEndTime; //Until what time the pool is active
    uint256 public TotalTokenAmount; //The total amount of the tokens for sale
    uint256 public TotalInvestors; // total number of investors in a particular pool
    uint256 public TotalCollectedWei;

    IERC20 public projectToken;
    IERC20 public tradeToken;

    struct Investor {
        uint256 Investment; //the amount of the main coin invested, calc with rate
        uint256 TokensOwn; //the amount of Tokens the investor needto get from the contract
        uint256 InvestTime; //the time that investment made
        bool Claimed;
    }

    mapping(address => Investor) public Investors;

    constructor(address _projectToken, address _tradeToken) public {
        projectToken = IERC20(_projectToken);
        tradeToken = IERC20(_tradeToken);
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

    modifier notYetClaimedOrRefunded() {
        require(!Investors[msg.sender].Claimed, "Already claimed or refunded");
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
        require(
            projectToken.balanceOf(msg.sender) >= _TotalTokenAmount,
            "ERC20: Balance is less than the total amount"
        );

        TransferInToken(address(projectToken), msg.sender, _TotalTokenAmount);
        PoolStartTime = _StartingTime;
        PoolEndTime = _StartingTime + (86400 * 7);
        // PoolEndTime = _StartingTime + 600;
        Goal = _goal;
        Cap = _cap;
        TotalTokenAmount = _TotalTokenAmount;
        LeftTokens = _TotalTokenAmount;
    }

    function Invest(uint256 _amount) external {
        require(block.timestamp >= PoolStartTime, "Not yet opened");
        require(block.timestamp < PoolEndTime, "Closed");
        require(
            SafeMath.add(TotalCollectedWei, _amount) <= Goal,
            "Pool token Goal has reached"
        );
        require(
            tradeToken.balanceOf(msg.sender) >= _amount && _amount != 0,
            "The sender does not have the requested trade tokens to send"
        );
        if (Cap != 0) {
            require(
                SafeMath.add(Investors[msg.sender].Investment, _amount) <= Cap,
                "There is a limit for each user to buy and this amount is over the limit"
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
                Investors[msg.sender].Investment
            );
        }

        tradeToken.transferFrom(msg.sender, address(this), _amount);

        TotalCollectedWei = SafeMath.add(TotalCollectedWei, _amount);
    }

    function claimTokens() external investorOnly notYetClaimedOrRefunded {
        require(hasPoolEnded(), "Pool has not ended yet");
        require(hasGoalReached(), "Pool has failed");

        Investors[msg.sender].Claimed = true; // make sure this goes first before transfer to prevent reentrancy

        uint256 Tokens = CalcTokens(Investors[msg.sender].Investment);

        projectToken.transfer(msg.sender, Tokens);
        Investors[msg.sender].TokensOwn = 0;
        emit TransferOut(Tokens, msg.sender, address(projectToken));

        RegisterClaim(Tokens);
    }

    function getRefund() external investorOnly notYetClaimedOrRefunded {
        require(hasPoolEnded(), "Pool has not ended yet");
        require(!hasGoalReached(), "Pool successful");

        Investors[msg.sender].Claimed = true; // make sure this goes first before transfer to prevent reentrancy
        uint256 investment = Investors[msg.sender].Investment;
        uint256 poolBalance = tradeToken.balanceOf(address(this));
        require(poolBalance > 0, "Balance of pool is zero");

        if (investment > poolBalance) {
            investment = poolBalance;
        }

        if (investment > 0) {
            tradeToken.transfer(msg.sender, investment);
            emit TransferOut(investment, msg.sender, address(tradeToken));
        }

        Investors[msg.sender].Investment = 0;
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

        Investors[_Sender] = Investor(_Amount, Tokens, block.timestamp, false);

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

    function withdrawProjectTokens() public onlyOwner {
        require(hasPoolEnded(), "Pool has not ended yet");
        uint256 balance = projectToken.balanceOf(address(this));
        require(balance >= 0, "Balance of pool is zero");
        projectToken.transfer(msg.sender, balance);
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
}
