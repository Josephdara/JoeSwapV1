// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/JDT.sol";
import "../src/Exchange.sol";

contract ExchangeTest is Test {
   Exchange public exchange;
   JDT public token;
   address kofo = vm.addr(3);

    function setUp() public {
        kofo.call{value: 1 * 10 **18}("");
        vm.startPrank(kofo);
        token = new JDT();
        exchange = new Exchange(address(token));
        vm.stopPrank();
    }

    function testValues() public view {
       console.log(exchange.name());
       console.log(exchange.symbol());
    }
    function testProvideTorevert() public{
         vm.expectRevert();
        exchange.provideLiquidity(100_000);
    
    }

      function testFail_ProvideLqt() public{
        token.approve(address(exchange), type(uint160).max);
        exchange.provideLiquidity(100_000);
       assertEq(exchange.getReserve(), 100_000);
       }
       function testProvideLqt() public payable {
        vm.startPrank(kofo);
        token.approve(address(exchange), type(uint160).max);
        exchange.provideLiquidity{value: 20_000}(100_000);
       assertEq(exchange.getReserve(), 100_000);
        vm.stopPrank();
       }
}
