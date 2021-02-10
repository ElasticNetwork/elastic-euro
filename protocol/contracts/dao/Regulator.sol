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
import "./Comptroller.sol";
import "../external/Decimal.sol";
import "../Constants.sol";

contract Regulator is Comptroller {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    event SupplyIncrease(uint256 indexed epoch, uint256 currentPriceInUSD, uint256 targetPriceInUSD, uint256 newRedeemable, uint256 lessDebt, uint256 newBonded);
    event SupplyDecrease(uint256 indexed epoch, uint256 currentPriceInUSD, uint256 targetPriceInUSD, uint256 newDebt);
    event SupplyNeutral(uint256 indexed epoch, uint256 currentPriceInUSD, uint256 targetPriceInUSD);

    function step(Decimal.D256 memory currentPriceInUSD, bool validCurrentPriceInUSD) internal {
        Decimal.D256 memory targetPriceInUSD;
        bool validTargetPriceInUSD;

        (targetPriceInUSD, validTargetPriceInUSD) = eurOracle().capture();
        if (bootstrappingAt(epoch().sub(1))) {
            if (!validTargetPriceInUSD) {
                targetPriceInUSD = Decimal.one();
            }

            currentPriceInUSD = targetPriceInUSD.mul(Constants.getBootstrappingPrice());
            validCurrentPriceInUSD = true;
        }

        if (!validCurrentPriceInUSD || !validTargetPriceInUSD) {
            emit SupplyNeutral(epoch(), Decimal.one().value, Decimal.one().value);
            return;
        }

        if (currentPriceInUSD.greaterThan(targetPriceInUSD)) {
            growSupply(currentPriceInUSD, targetPriceInUSD);
            return;
        }

        if (currentPriceInUSD.lessThan(targetPriceInUSD)) {
            shrinkSupply(currentPriceInUSD, targetPriceInUSD);
            return;
        }

        emit SupplyNeutral(epoch(), currentPriceInUSD.value, targetPriceInUSD.value);
    }

    function shrinkSupply(Decimal.D256 memory currentPriceInUSD, Decimal.D256 memory targetPriceInUSD) private {
        Decimal.D256 memory delta = limit(Decimal.one().sub(currentPriceInUSD.div(targetPriceInUSD)), false);
        uint256 newDebt = delta.mul(totalNet()).asUint256();
        uint256 cappedNewDebt = increaseDebt(newDebt);

        emit SupplyDecrease(epoch(), currentPriceInUSD.value, targetPriceInUSD.value, cappedNewDebt);
        return;
    }

    function growSupply(Decimal.D256 memory currentPriceInUSD, Decimal.D256 memory targetPriceInUSD) private {
        uint256 lessDebt = resetDebt(Decimal.zero());

        Decimal.D256 memory delta = limit(currentPriceInUSD.div(targetPriceInUSD).sub(Decimal.one()), true);
        uint256 newSupply = delta.mul(totalNet()).asUint256();
        (uint256 newRedeemable, uint256 newBonded) = increaseSupply(newSupply);
        emit SupplyIncrease(epoch(), currentPriceInUSD.value, targetPriceInUSD.value, newRedeemable, lessDebt, newBonded);
    }

    function limit(Decimal.D256 memory delta, bool expansion) private view returns (Decimal.D256 memory) {
        if ( bootstrappingAt(epoch().sub(1)) ) {
            return delta;
        }

        Decimal.D256 memory supplyChangeLimit = Constants.getSupplyChangeLimit();

        uint256 totalRedeemable = totalRedeemable();
        uint256 totalCoupons = totalCoupons();
        if (expansion && (totalRedeemable < totalCoupons)) {
            supplyChangeLimit = Constants.getCouponSupplyChangeLimit();
        }

        return delta.greaterThan(supplyChangeLimit) ? supplyChangeLimit : delta;
    }
}
