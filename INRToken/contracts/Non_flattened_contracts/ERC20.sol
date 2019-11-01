pragma solidity ^0.5.0;

import "./IERC.sol";
import "./SafeMath.sol";
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

