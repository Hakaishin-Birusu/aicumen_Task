pragma solidity ^0.5.0;

import "./ERC20.sol";
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
    */
    constructor() public payable {
      _name = "INRToken";
      _symbol = "INRT";
      _decimals = 18;
      uint256 totalSupply = 1000000000000000000;
      // Since its a fixed supply ERC token , all the tokens are minted to contract deployer
      _mint(msg.sender, totalSupply);

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