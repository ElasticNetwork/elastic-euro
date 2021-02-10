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
import "./State.sol";
import "../Constants.sol";
import "../pool/StakingRewards.sol";

contract Getters is State {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * ERC20 Interface
     */

    function name() public pure returns (string memory) {
        return "Elastic Euro Stake";
    }

    function symbol() public pure returns (string memory) {
        return "eEURS";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _state.accounts[account].balance;
    }

    function totalSupply() public view returns (uint256) {
        return _state.balance.supply;
    }

    function allowance(address /* owner */, address /* spender */) external pure returns (uint256) {
        return 0;
    }

    /**
     * Global
     */

    function euro() public view returns (IEuro) {
        return _state.provider.euro;
    }

    function oracle() public view returns (IOracle) {
        return _state.provider.oracle;
    }

    function eurOracle() public view returns (IOracle) {
        return _state.provider.eurOracle;
    }

    function pool() public view returns (address) {
        return _state.provider.pool;
    }

    function totalBonded() public view returns (uint256) {
        return _state.balance.bonded;
    }

    function totalStaged() public view returns (uint256) {
        return _state.balance.staged;
    }

    function totalDebt() public view returns (uint256) {
        return _state.balance.debt;
    }

    function totalRedeemable() public view returns (uint256) {
        return _state.balance.redeemable;
    }

    function totalCouponUnderlying() public view returns (uint256) {
        return _state.couponUnderlying;
    }


    function totalCoupons() public view returns (uint256) {
        return _state.balance.coupons;
    }

    function totalNet() public view returns (uint256) {
        if (bootstrappingAt(epoch().sub(1))) {
            return euro().totalSupply().sub(Constants.getBootstrappingPoolReward()).sub(totalDebt());
        }

        return euro().totalSupply().sub(totalDebt());
    }

    function totalTreasuryCoins(address coin) public view returns (uint256) {
        return _state.treasuryCoins[coin].balance;
    }

    /**
     * Account
     */

    function balanceOfStaged(address account) public view returns (uint256) {
        return _state.accounts[account].staged;
    }

    function balanceOfBonded(address account) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            return 0;
        }
        return totalBonded().mul(balanceOf(account)).div(_totalSupply);
    }

    function balanceOfCoupons(address account, uint256 _epoch) public view returns (uint256) {
        if (outstandingCoupons(_epoch) == 0) {
            return 0;
        }
        return _state.accounts[account].coupons[_epoch];
    }

    function balanceOfCouponUnderlying(address account, uint256 epoch) public view returns (uint256) {
        return _state.couponUnderlyingByAccount[account][epoch];
    }

    function statusOf(address account) public view returns (Account.Status) {
        if (_state.accounts[account].lockedUntil > epoch()) {
            return Account.Status.Locked;
        }

        return epoch() >= _state.accounts[account].fluidUntil ? Account.Status.Frozen : Account.Status.Fluid;
    }

    function fluidUntil(address account) public view returns (uint256) {
        return _state.accounts[account].fluidUntil;
    }

    function lockedUntil(address account) public view returns (uint256) {
        return _state.accounts[account].lockedUntil;
    }

    function allowanceCoupons(address owner, address spender) public view returns (uint256) {
        return _state.accounts[owner].couponAllowances[spender];
    }

    /**
     * Epoch
     */

    function epoch() public view returns (uint256) {
        return _state.epoch.current;
    }

    function epochTime() public view returns (uint256) {
        return epochTimeWithStrategy(Constants.getEpochStrategy());
    }

    function epochTimeWithStrategy(Constants.EpochStrategy memory strategy) private view returns (uint256) {
        return blockTimestamp()
        .sub(strategy.start)
        .div(strategy.period)
        .add(strategy.offset);
    }

    // Overridable for testing
    function blockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    function outstandingCoupons(uint256 _epoch) public view returns (uint256) {
        return _state.epochs[_epoch].coupons.outstanding;
    }

    function couponsExpiration(uint256 _epoch) public view returns (uint256) {
        return _state.epochs[_epoch].coupons.expiration;
    }

    function expiringCoupons(uint256 _epoch) public view returns (uint256) {
        return _state.epochs[_epoch].coupons.expiring.length;
    }

    function expiringCouponsAtIndex(uint256 _epoch, uint256 i) public view returns (uint256) {
        return _state.epochs[_epoch].coupons.expiring[i];
    }

    function totalBondedAt(uint256 _epoch) public view returns (uint256) {
        return _state.epochs[_epoch].bonded;
    }

    function bootstrappingAt(uint256 _epoch) public pure returns (bool) {
        return _epoch <= Constants.getBootstrappingPeriod();
    }

    function poolBootstrapping() public view returns (bool) {
        return StakingRewards(pool()).periodFinish() > block.timestamp;
    }

    /**
     * Governance
     */

    function recordedVote(address account, address candidate) public view returns (Candidate.Vote) {
        return _state.candidates[candidate].votes[account];
    }

    function startFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].start;
    }

    function periodFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].period;
    }

    function approveFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].approve;
    }

    function rejectFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].reject;
    }

    function votesFor(address candidate) public view returns (uint256) {
        return approveFor(candidate).add(rejectFor(candidate));
    }

    function isNominated(address candidate) public view returns (bool) {
        return _state.candidates[candidate].start > 0;
    }

    function isInitialized(address candidate) public view returns (bool) {
        return _state.candidates[candidate].initialized;
    }

    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}
