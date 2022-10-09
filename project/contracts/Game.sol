// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Game is VRFConsumerBaseV2 {
    uint256 N;
    address public owner;
    uint256 public stakeAmount;
    VRFCoordinatorV2Interface vrfCoordinator;
    bytes32 public gasLane;
    uint64 public subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    mapping(address => uint256) public balance;
    mapping(address => uint256) private amountStaked;

    // uint256 decimal = 1-0.01;
    // ufixed8x2 contract_balance = address(this).balance;

    event RequestedWinner(uint256 indexed requestId);

    address payable nowWinner;

    constructor(
        address vrfCoordinatorV2,
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        gasLane = _gasLane;
        subscriptionId = _subscriptionId;
        callbackGasLimit = _callbackGasLimit;
    }

    address payable[] public players;

    modifier onlyOwner() {
        owner = msg.sender;
        _;
    }

    modifier notOwner() {
        require(owner != msg.sender);
        _;
    }

    uint256 _stakeAmount = 1;

    function initialize(uint256 n) public onlyOwner {
        require(n >= 3, "Minimum 3 players");
        N = n;
        stakeAmount = _stakeAmount * 10**18;
    }

    function stake() public payable notOwner {
        require(msg.value >= stakeAmount);
        players.length == N - 1;
        if (msg.value > stakeAmount) {
            balance[msg.sender] -= msg.value;
            balance[address(this)] += msg.value;
        }
        players.push(payable(msg.sender));
    }

    function unstake() public payable {
        balance[address(this)] -= msg.value;
        balance[msg.sender] += msg.value;
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % players.length;
        address payable recentWinner = players[indexOfWinner];
        nowWinner = recentWinner;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        require(success);
    }
}
