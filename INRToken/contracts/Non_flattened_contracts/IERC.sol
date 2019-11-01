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
