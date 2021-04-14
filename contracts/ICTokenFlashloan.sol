pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface ICTokenFlashloan {
    function flashLoan(address receiver, uint amount, bytes calldata params) external;
}
