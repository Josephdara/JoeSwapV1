// SPDX-License-Identifier:MIT 
pragma solidity 0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {INAME, IFactory} from "./Interfaces.sol";

contract Exchange is ERC20 {
    using SafeERC20 for IERC20;

    address public erc20Address;
    address public factoryAddress;

    constructor(address _token) ERC20(string.concat(INAME(_token).name(), " ",  "LP"  ) , string.concat( INAME(_token).symbol() , "LP") ) {
        require(_token != address(0));
        erc20Address = _token;
         factoryAddress = msg.sender;
    }
    function provideLiquidity(uint256 amount) public payable returns (uint256) {
        if (getReserve() == 0) {
            IERC20 token = IERC20(erc20Address);
            token.safeTransferFrom(msg.sender, address(this), amount);
            uint256 liquidity = address(this).balance;
            _mint(msg.sender, liquidity);

            return liquidity;
        } else {
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = getReserve();
            uint256 tokenAmount = (msg.value * tokenReserve) / ethReserve;
            require(amount >= tokenAmount, "insufficient token amount");

            IERC20 token = IERC20(erc20Address);
            token.safeTransferFrom(msg.sender, address(this), tokenAmount);
            uint256 liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);

            return liquidity;
        }
    }

    function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
        require(_amount > 0, "invalid amount");

        uint256 ethAmount = (address(this).balance * _amount) / totalSupply();
        uint256 tokenAmount = (getReserve() * _amount) / totalSupply();

        _burn(msg.sender, _amount);
          (bool s,) = payable(msg.sender).call{value:ethAmount}("");
        require(s, "Transfer failed");
        IERC20(erc20Address).transfer(msg.sender, tokenAmount);

        return (ethAmount, tokenAmount);
    }

    function getReserve() public view returns (uint256) {
        return IERC20(erc20Address).balanceOf(address(this));
    }

    function getAmount( uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) private pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        uint256 inputAmountWithFee = inputAmount * 99;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
         return numerator / denominator;
    }

    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "ethSold is too small");
        uint256 tokenReserve = getReserve();
        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "tokenSold is too small");
        uint256 tokenReserve = getReserve();
        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    function ethToToken(uint256 _minTokens, address recipient) private {
        uint256 tokenReserve = getReserve();
         uint256 tokensBought = getAmount(
             msg.value,
             address(this).balance - msg.value,
             tokenReserve
            );

        require(tokensBought >= _minTokens, "insufficient output amount");

         IERC20(erc20Address).transfer(recipient, tokensBought);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
         ethToToken(_minTokens, msg.sender);
    }
    function ethToTokenTransfer(uint256 _minTokens, address _recipient) public payable {
        ethToToken(_minTokens, _recipient);
    }



    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmount(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );

        require(ethBought >= _minEth, "insufficient output amount");

        IERC20(erc20Address).safeTransferFrom(msg.sender, address(this), _tokensSold);
        (bool s,) = payable(msg.sender).call{value:ethBought}("");
        require(s, "Transfer failed");
    }

    function tokenToTokenSwap( uint256 _tokensSold, uint256 _minTokensBought, address _tokenAddress) public {
        address exchangeAddress = IFactory(factoryAddress).getExchange(_tokenAddress );
        require(
        exchangeAddress != address(this) && exchangeAddress != address(0),
        "invalid exchange address");
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmount(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );

        IERC20(erc20Address).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );
       
    Exchange(exchangeAddress).ethToTokenTransfer{value: ethBought}( _minTokensBought, msg.sender);
    
    }
    
}