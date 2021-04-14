pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./IFlashloanReceiver.sol";
import "./ICTokenFlashloan.sol";
import "./Nerve.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


import "hardhat/console.sol";

contract StableArbitrator is IFlashloanReceiver {


    struct Opportunity {
        address borrowToken;
        address intermediaryToken;
    }

    function performArbitrage(
        address borrowToken,
        address intermediaryToken,
        uint256 borrowAmount) public {
        bytes memory data = abi.encode(
            Opportunity({
        borrowToken : borrowToken,
        intermediaryToken : intermediaryToken
        })
        );

        // call the flashLoan method
        ICTokenFlashloan(borrowToken).flashLoan(address(this), borrowAmount, data);
    }

    // this function is called after your contract has received the flash loaned amount
    function executeOperation(address sender, address underlying, uint amount, uint fee, bytes calldata _params) override external {
        address cToken = msg.sender;


        uint currentBalance = IERC20(underlying).balanceOf(address(this));
        require(currentBalance >= amount, "Invalid balance, was the flashLoan successful?");

        Opportunity memory opportunity = abi.decode(_params, (Opportunity));

        // transfer fund + fee back to cToken
        require(IERC20(underlying).transfer(cToken, amount + fee), "Transfer fund back failed");
    }

    function swapNerve(address fromToken, address toToken, uint256 amount) private returns (uint256) {
        Nerve nerve = Nerve(0x1B3771a66ee31180906972580adE9b81AFc5fCDc);
        uint8 fromIndex = nerve.getTokenIndex(fromToken);
        uint8 toIndex = nerve.getTokenIndex(toToken);

        return nerve.swap(fromIndex, toIndex, amount, 0, 0);
    }
}