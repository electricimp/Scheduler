@include "tests/Scheduler/At.nut"

function _calcTime() {
    return hardware.millis() / 1000.0;
}

function _calcDate() {
    return hardware.millis() / 1000.0;
}

function _calcError(firedTime, setTime) {
    if (typeof firedTime == "integer" || typeof firedTime == "float") {
        return firedTime - setTime;
    } else if (typeof firedTime == "table") {
        return firedTime.time - setTime;
    }
}
