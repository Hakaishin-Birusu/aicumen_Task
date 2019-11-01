
// File: contracts/Non_flattened_contracts/IERC.sol

pragma solidity ^0.5.0;

/**
 * @author Sagar Chaurasia
 * @dev ERC20 interface (i have done implemantation of these function of interface in another smart contract)
 */
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender ,address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/Non_flattened_contracts/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/Non_flattened_contracts/ERC20.sol

pragma solidity ^0.5.0;


/**
 * @author Sagar Chaurasia
 * @dev Implementation of the `IERC20` interface.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    address setEntity;

    /**
     * @dev creating modifier for giving access to modules to set entity only
     * where set entity is contractaddress of AcuConverter
     */
    modifier OnlySetEntity() {
        require(msg.sender == setEntity , "Authorization failed, not set entity");
        _;
    } 

    /**
     * @dev retunrs total number of tokens.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev check balance of tokens for specific entity.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev transfer tokens from sender to reciever.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev defining explicit arguments for transferring tokens
     * as security mesure only set entities can carry out this method
     */
     function transferFrom(address sender ,address recipient, uint256 amount) public OnlySetEntity returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }


    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     */
    function _mint(address account, uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

}

// File: contracts/Non_flattened_contracts/INRToken.sol

pragma solidity ^0.5.0;

// Instead of manual storing of ERC20contracts we could have used open-zepplin git import link but since we wanted to define only needed functions
// thats why we stoed it locally and defined as per need
/**
 * @title INRToken
 * @author Sagar Chaurasia
 */
contract INRToken is ERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
    *  Note : everything can be passed as parmeter (and same contract can be used for deploying USDT and INRT can be use ) ,
    * but for task understanidng and simplicity i have hardcoded gthe values here
    * Here , _t is the address of acuConverter
    */
    constructor(address _t) public payable {
      _name = "INRToken";
      _symbol = "INRT";
      _decimals = 18;
      uint256 totalSupply = 1000000000000000000;
      // Since its a fixed supply ERC token , all the tokens are minted to contract deployer
      _mint(msg.sender, totalSupply);
      setEntity = _t;

    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value number of tokens to be burned.
     */
    function burn(address burnFrom,  uint256 value) public {
      _burn(burnFrom, value);
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
      return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
      return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
      return _decimals;
    }
    
}
