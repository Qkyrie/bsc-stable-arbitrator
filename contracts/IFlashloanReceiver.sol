pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface IFlashloanReceiver {
    function executeOperation(address sender, address underlying, uint amount, uint fee, bytes calldata params) external;
}