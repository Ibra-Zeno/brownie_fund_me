// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol"; //this is an npm package. Brownie cannot download from npm directly.

//Brownie can download from github

/* Above we have an interface
    - An interface is a contract with a list of function definitions without implementation */
// Interfaces compile down to an ABI
// We always need an ABI to interact with another contract

//Library: deployed only once at a specific address and their code is re-used.

contract FundMe {
    //using SafeMathChainlink for uint256;
    //using A for B - we attach a library function (A) to any type (B) in contract

    //We can keep track of who funded what by mapping
    //Below we link address to amount funded
    mapping(address => uint256) public addressToAmountFunded;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        //Threshold
        require(
            getConversionRate(msg.value) > 20 * 10**18,
            "This is a prompt if you fail to comply"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        //When we call fund, we save address of sender and associated value
        //When we send funds to this contract, the contract holds the ether
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        /* Here we have too many unused local variables but latestRoundData must return
        5 outputs. So we use blanks in the tuple to signify we only want one returned
        (uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound) = priceFeed.latestRoundData(); 
        === ...*/

        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //Above we have used a tuple
        // A tuple: Anonymous collection of multiple values
        return uint256(answer * 10000000000); //returns price of one ETH/USD rate in 18 digit
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Naughty, naughty");
        _;
    }

    //Modifiers alter behaviour of a function. Just put modifier name into fucnction (below)

    //Withdraw money
    function withdraw() public payable onlyOwner {
        //note inclusion of modifier
        payable(msg.sender).transfer(address(this).balance);
        //whoever calls withdraw function is msg.sender and whole balance is sent
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        //new address array of size 0 (still dynamic)
    }
}
