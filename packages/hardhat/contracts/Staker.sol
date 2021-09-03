pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    event Stake(address staker, uint256 quantity);

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = now + 30 seconds;
    bool public openForWithdraw = false;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() public payable {
        require(timeLeft() == 0, "Can't execute this method before deadline");
        if (address(this).balance > threshold) {
            // Goal acomplished
            exampleExternalContract.complete{value: address(this).balance}(); // Do the work
        } else {
            openForWithdraw = true; // Withdraw funds
        }
    }

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function

    function withdraw(address payable _to) public payable {
        require(openForWithdraw, "Contract is not open for withdraw");
        if (openForWithdraw) {
            // Withdraw all balance
            uint256 amount = address(this).balance;

            (bool success, ) = _to.call{value: amount}("");
            require(success, "Failed to send Ether");
        }
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    function timeLeft() public view returns (uint256) {
        if (now >= deadline) {
            return 0;
        }
        return deadline - now;
    }
}
