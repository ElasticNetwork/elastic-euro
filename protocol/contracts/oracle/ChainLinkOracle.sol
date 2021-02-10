pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./IOracle.sol";
import "../external/Decimal.sol";
import "../external/Require.sol";
import "@chainlink/contracts-0.0.10/src/v0.5/interfaces/AggregatorV2V3Interface.sol";


contract ChainLinkOracle is IOracle {
    using Decimal for Decimal.D256;

    bytes32 private constant FILE = "ChainLinkOracle";
    address private constant EUR_USD = address(0xb49f677943BC038e9857d61E7d053CaA2C1734C1); // mainnet

    address internal _dao;
    AggregatorV2V3Interface private priceFeed;


    constructor() public {
        _dao = msg.sender;
    }

    function setup() public onlyDao {
        priceFeed = AggregatorV2V3Interface(EUR_USD);
    }

    function capture() public onlyDao returns (Decimal.D256 memory, bool) {
        return (Decimal.D256(uint256(priceFeed.latestAnswer()) * 1e10), true);
    }

    function pair() external view returns (address) {
        return address(0);
    }

    modifier onlyDao() {
        Require.that(
            msg.sender == _dao,
            FILE,
            "Not dao"
        );

        _;
    }
}