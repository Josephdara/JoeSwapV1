// SPDX-License-Identifier:MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract JDT is ERC20 {

    
    address public deployer;
    uint256 public immutable maxSupply;

    constructor() ERC20("Joseph Dara Token", "JDT") {
        deployer = msg.sender;
        maxSupply = 1_000_000 * 10 ** decimals();
        _mint(msg.sender, 250_000 * 10 ** decimals());
    }
    function mint(uint256 _amount) external {
        require(deployer == msg.sender, "not the deployer");
        require(totalSupply() + _amount <= maxSupply, "greater than maxSupply");
        _mint(msg.sender, _amount);
    }
}