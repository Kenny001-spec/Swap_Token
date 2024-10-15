// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {IERC20} from "./IERC20.sol";


contract SwapToken {

    IERC20 public baseToken;
    IERC20 public usdtToken;
    address owner;
    bool internal locked;
    uint256 internal constant ONE_USDT_TO_BASE = 2100;

    enum Currency {NONE, BASE, USDT }

    mapping (Currency => uint256)  contractBalances;

    constructor(IERC20 _baseTokenCAddr, IERC20 _usdtTokenCAddr){
        baseToken = _baseTokenCAddr;
        usdtToken = _usdtTokenCAddr;
        owner = msg.sender;
    }

    event SwapSuccessful(address indexed from, address indexed to, uint256 amount);
    event WithdrawSuccessful(address indexed owner, Currency indexed _currencyName, uint256 amount);


    modifier reentrancyGuard() {
        require(!locked, "Reentrancy not allowed");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can access");
        _;
    }


    function swapBaseToUsdt(address _from, uint256 _amount) external reentrancyGuard  {
        require(msg.sender != address(0), "Zero not allowed");
        require(_amount > 0 , "Cannot swap zero amount");

        uint256 standardAmount = _amount * 10**18;

        uint256 userBal = baseToken.balanceOf(msg.sender);

        require(userBal >= _amount, "Your balance is not enough");

        uint256 allowance = baseToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Token allowance too low");


        bool deducted = baseToken.transferFrom(_from, address(this), standardAmount);

        require(deducted, "Excution failed");

        contractBalances[Currency.BASE] +=  standardAmount;


        uint256 convertedValue_ = Base_Usdt_Rate(standardAmount, Currency.BASE);

        bool swapped = usdtToken.transfer(msg.sender, convertedValue_);


        if (swapped) {

            contractBalances[Currency.USDT] +=  convertedValue_;

            emit SwapSuccessful(_from, address(this), standardAmount );
        }

    }




    function swapUsdtToBase(address _from, uint256 _amount) external reentrancyGuard {
    require(msg.sender != address(0), "Zero not allowed");
    require(_amount > 0, "Cannot swap zero amount");

    
    uint256 standardAmount = _amount * 10**6;

    uint256 userBal = usdtToken.balanceOf(msg.sender);
    require(userBal >= standardAmount, "Your balance is not enough");

    uint256 allowance = usdtToken.allowance(msg.sender, address(this));
    require(allowance >= standardAmount, "Token allowance too low");

    bool deducted = usdtToken.transferFrom(_from, address(this), standardAmount);
    require(deducted, "Execution failed");

    contractBalances[Currency.USDT] += standardAmount;

    uint256 convertedValue_ = Base_Usdt_Rate(standardAmount, Currency.USDT);
    bool swapped = baseToken.transfer(msg.sender, convertedValue_);

    if (swapped) {
        contractBalances[Currency.BASE] += convertedValue_;
        emit SwapSuccessful(_from, address(this), standardAmount);
    }
}



        function getContractBalance() external view onlyOwner returns (uint256 contractUsdtbal_, uint256 contractBasel_) {
        contractUsdtbal_ = usdtToken.balanceOf(address(this));
        contractBasel_ = baseToken.balanceOf(address(this));
    }


      function withdraw(Currency _currencyName, uint256 _amount) external onlyOwner  {
        require(_amount > 0, "balance is less");

        uint256 bal = contractBalances[_currencyName];

        require(bal >= _amount, "Insufficient contract balance");


        if(Currency.BASE == _currencyName) {

         baseToken.transfer(msg.sender, _amount);

         
        emit WithdrawSuccessful(msg.sender, _currencyName, _amount);


        }else  if(Currency.USDT == _currencyName) {
         usdtToken.transfer(msg.sender, _amount);

         
        emit WithdrawSuccessful(msg.sender, _currencyName, _amount);


        }

        revert("Token not defined");
    }



 function Base_Usdt_Rate (uint256 _amount, Currency _currency) internal pure returns (uint256 convertedValue_) {
        if(_currency == Currency.USDT) {
            convertedValue_ = _amount * ONE_USDT_TO_BASE;  
        } else if(_currency == Currency.BASE) {
            convertedValue_ = _amount  / ONE_USDT_TO_BASE ;
        } else {
            revert("Unsupported currency");
        }
        return convertedValue_;
    }
}
