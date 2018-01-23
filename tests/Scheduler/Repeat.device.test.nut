@include "tests/Scheduler/Repeat.nut"

function _calcTime() {
    return hardware.millis() / 1000.0;
}

function _calcError(firedTime, setTime) {
    return firedTime - setTime;
}

function _incrementTime(setTime, interval) {
        return setTime += interval;
}
