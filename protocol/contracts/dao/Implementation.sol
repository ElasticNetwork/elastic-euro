/*
    Copyright 2020 Elastic Network, based on the work of Empty Set Squad and Dynamic Dollar Devs <elasticnetwork@protonmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Market.sol";
import "./Regulator.sol";
import "./Bonding.sol";
import "./Govern.sol";
import "../Constants.sol";
import "../pool/StakingRewards.sol";
import "../external/Decimal.sol";

contract DAO is State, Bonding, Market, Regulator, Govern {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() initializer public {
        // Reward committer
        mintToAccount(msg.sender, 100e18);
    }

    function advanceEpoch() external {
        (Decimal.D256 memory currentPriceInUSD, bool validCurrentPriceInUSD) = oracle().capture();
        incentivize(msg.sender, calculateAdvanceReward(currentPriceInUSD));

        Bonding.step();
        Regulator.step(currentPriceInUSD, validCurrentPriceInUSD);
        Market.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }

    function incentivize(address account, uint256 amount) private {
        mintToAccount(account, amount);
        emit Incentivization(account, amount);
    }

    function calculateAdvanceReward(Decimal.D256 memory currentPriceInUSD) internal returns (uint256) {
        Decimal.D256 memory reward = Constants.getAdvanceIncentiveDollar().div(currentPriceInUSD);

        if (reward.value > 1e21) {
            return 1e21;
        }

        return reward.value;
    }
}
