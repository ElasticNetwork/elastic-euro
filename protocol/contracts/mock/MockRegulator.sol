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

import "../dao/Regulator.sol";
import "../oracle/IOracle.sol";
import "./MockComptroller.sol";
import "./MockState.sol";
import "../external/Decimal.sol";

contract MockRegulator is MockComptroller, Regulator {
    using Decimal for Decimal.D256;

    constructor (address oracle, address eurOracle, address pool) MockComptroller(pool) public {
        _state.provider.oracle = IOracle(oracle);
        _state.provider.eurOracle = IOracle(eurOracle);
    }

    function stepE() external {
        (Decimal.D256 memory price, bool valid) = _state.provider.oracle.capture();
        super.step(price, valid);
    }

    function bootstrappingAt(uint256 epoch) public pure returns (bool) {
        return epoch <= 5;
    }
}
