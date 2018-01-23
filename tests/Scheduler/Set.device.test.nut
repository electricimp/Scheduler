@include "tests/Scheduler/Set.nut"

function _calcTime() {
    return hardware.millis() / 1000.0;
}

function _calcError(firedTime, setTime) {
    return firedTime - setTime;
}
