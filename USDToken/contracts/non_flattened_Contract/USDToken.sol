pragma solidity ^0.5.0;

import "./ERC20.sol";
/**
 * @title USDToken
 * @author Sagar Chaurasia
 */
contract USDToken is ERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

/**
    *  Note : everything can be passed as parmeter (and same contract can be used for deploying USDT and INRT can be use ) ,
    * but for task understanidng and simplicity i have hardcoded gthe values here
    * Here , _t is the address of acuConverter
    * NOTE 2: 2 point decimal precision will leverage us to carry out any token related transaction in cents/paise , 
    * in the same way where ether transaction deals with wei (18 point decimal)
    * We have implemanted fixed supply token erc20 standard and , minitng only 10000 USD tokens or 1000000 cent tokens 
    */
    constructor(address _t) public payable {
      _name = "USDToken";
      _symbol = "USDT";
      _decimals = 2;
      uint256 totalSupply = 1000000;

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

    // optional functions from ERC20 stardard

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