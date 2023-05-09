// SPDX-License-Identifier:MIT 
pragma solidity 0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./INAME.sol";

contract Exchange is ERC20 {
    using SafeERC20 for IERC20;

    address public erc20Address;
    constructor(address _token) ERC20(string.concat(INAME(_token).name(), " ",  "LP"  ) , string.concat( INAME(_token).symbol() , "LP") ) {
        require(_token != address(0));
        erc20Address = _token;
    }
    
}