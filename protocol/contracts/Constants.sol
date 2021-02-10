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

import "./external/Decimal.sol";

library Constants {
    /* Chain */
    uint256 private constant CHAIN_ID = 1; // Development - 1337, Rinkeby - 4, Mainnet - 1

    /* Bootstrapping */
    uint256 private constant BOOTSTRAPPING_PERIOD = 90;
    uint256 private constant BOOTSTRAPPING_PRICE = 11e17; // 10% higher
    uint256 private constant BOOTSTRAPPING_POOL_REWARD = 100000e18; // 100k eEUR


    /* Oracle */
    address private constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // mainnet
    uint256 private constant ORACLE_RESERVE_MINIMUM = 10000e6; // 10,000 USDC

    /* Bonding */
    uint256 private constant INITIAL_STAKE_MULTIPLE = 1e6; // 100 eEUR -> 100M eEURS

    /* Epoch */
    struct EpochStrategy {
        uint256 offset;
        uint256 start;
        uint256 period;
    }

    uint256 private constant EPOCH_OFFSET = 0;
    uint256 private constant EPOCH_START = 1610812800;
    uint256 private constant EPOCH_PERIOD = 28800;

    /* Governance */
    uint256 private constant GOVERNANCE_PERIOD = 9; // 9 epochs
    uint256 private constant GOVERNANCE_EXPIRATION = 2; // 2 + 1 epochs
    uint256 private constant GOVERNANCE_QUORUM = 20e16; // 20%
    uint256 private constant GOVERNANCE_PROPOSAL_THRESHOLD = 5e15; // 0.5%
    uint256 private constant GOVERNANCE_SUPER_MAJORITY = 66e16; // 66%
    uint256 private constant GOVERNANCE_EMERGENCY_DELAY = 6; // 6 epochs

    /* DAO */
    uint256 private constant ADVANCE_INCENTIVE_DOLLAR = 150e18;
    uint256 private constant DAO_EXIT_LOCKUP_EPOCHS = 15; // 15 epochs fluid

    /* Pool */
    uint256 private constant POOL_EXIT_LOCKUP_EPOCHS = 5; // 5 epochs fluid

    /* Market */
    uint256 private constant COUPON_EXPIRATION = 90;
    uint256 private constant DEBT_RATIO_CAP = 15e16; // 15%
    uint256 private constant INITIAL_COUPON_REDEMPTION_PENALTY = 50e16; // 50%
    uint256 private constant COUPON_REDEMPTION_PENALTY_DECAY = 3600; // 1 hour

    /* Regulator */
    uint256 private constant SUPPLY_CHANGE_LIMIT = 3e16; // 3%
    uint256 private constant COUPON_SUPPLY_CHANGE_LIMIT = 6e16; // 6%
    uint256 private constant ORACLE_POOL_RATIO = 20; // 20%

    uint256 private constant TREASURY_RATIO = 250; // 2.5%

    /* Deployed */
    //TODO(laireht): Uncomment and replace with new addresses after first deployment
    //    address private constant DAO_ADDRESS = address(0);
    //    address private constant DOLLAR_ADDRESS = address(0);
    //    address private constant PAIR_ADDRESS = address(0);

    /**
     * Getters
     */

    function getUsdcAddress() internal pure returns (address) {
        return USDC;
    }

    function getOracleReserveMinimum() internal pure returns (uint256) {
        return ORACLE_RESERVE_MINIMUM;
    }

    function getEpochStrategy() internal pure returns (EpochStrategy memory) {
        return EpochStrategy({
        offset : EPOCH_OFFSET,
        start : EPOCH_START,
        period : EPOCH_PERIOD
        });
    }

    function getEpochPeriod() internal pure returns (uint256) {
        return EPOCH_PERIOD;
    }

    function getInitialStakeMultiple() internal pure returns (uint256) {
        return INITIAL_STAKE_MULTIPLE;
    }

    function getBootstrappingPeriod() internal pure returns (uint256) {
        return BOOTSTRAPPING_PERIOD;
    }

    function getBootstrappingPrice() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : BOOTSTRAPPING_PRICE});
    }

    function getBootstrappingPoolReward() internal pure returns (uint256) {
        return BOOTSTRAPPING_POOL_REWARD;
    }

    function getGovernancePeriod() internal pure returns (uint256) {
        return GOVERNANCE_PERIOD;
    }

    function getGovernanceExpiration() internal pure returns (uint256) {
        return GOVERNANCE_EXPIRATION;
    }

    function getGovernanceQuorum() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : GOVERNANCE_QUORUM});
    }

    function getGovernanceProposalThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : GOVERNANCE_PROPOSAL_THRESHOLD});
    }

    function getGovernanceSuperMajority() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : GOVERNANCE_SUPER_MAJORITY});
    }

    function getGovernanceEmergencyDelay() internal pure returns (uint256) {
        return GOVERNANCE_EMERGENCY_DELAY;
    }

    function getAdvanceIncentiveDollar() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : ADVANCE_INCENTIVE_DOLLAR});
    }

    function getDAOExitLockupEpochs() internal pure returns (uint256) {
        return DAO_EXIT_LOCKUP_EPOCHS;
    }

    function getPoolExitLockupEpochs() internal pure returns (uint256) {
        return POOL_EXIT_LOCKUP_EPOCHS;
    }

    function getCouponExpiration() internal pure returns (uint256) {
        return COUPON_EXPIRATION;
    }

    function getDebtRatioCap() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : DEBT_RATIO_CAP});
    }

    function getSupplyChangeLimit() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : SUPPLY_CHANGE_LIMIT});
    }

    function getCouponSupplyChangeLimit() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : COUPON_SUPPLY_CHANGE_LIMIT});
    }

    function getOraclePoolRatio() internal pure returns (uint256) {
        return ORACLE_POOL_RATIO;
    }

    function getTreasuryRatio() internal pure returns (uint256) {
        return TREASURY_RATIO;
    }

    function getChainId() internal pure returns (uint256) {
        return CHAIN_ID;
    }

    function getInitialCouponRedemptionPenalty() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value : INITIAL_COUPON_REDEMPTION_PENALTY});
    }

    function getCouponRedemptionPenaltyDecay() internal pure returns (uint256) {
        return COUPON_REDEMPTION_PENALTY_DECAY;
    }



    //    function getDaoAddress() internal pure returns (address) {
    //        return DAO_ADDRESS;
    //    }
    //
    //    function getDollarAddress() internal pure returns (address) {
    //        return DOLLAR_ADDRESS;
    //    }
    //
    //    function getPairAddress() internal pure returns (address) {
    //        return PAIR_ADDRESS;
    //    }
    //
}
