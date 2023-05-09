// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/JDT.sol";
import "../src/Exchange.sol";

contract ExchangeTest is Test {
   Exchange public exchange;
   JDT public token;

    function setUp() public {
        token = new JDT();
        exchange = new Exchange(address(token));
    }

    function testValues() public view {
       console.log(exchange.name());
       console.log(exchange.symbol());
    }

   
}
