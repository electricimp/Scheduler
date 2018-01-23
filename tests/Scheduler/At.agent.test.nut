@include "tests/Scheduler/At.nut"

function _calcTime() {
    return time();    
}

function _calcDate() {
    return date();    
}

function _calcError(firedDate, setTime) {
    return (firedDate.time - setTime) + (firedDate.usec / 1000000.0);
}
