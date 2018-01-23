@include "tests/Scheduler/Set.nut"

function _calcTime() {
    return date();
}

function _calcError(firedTime, setTime) {
    return ((firedTime.time - setTime.time) + (firedTime.usec - setTime.usec) / 1000000.0);
}
