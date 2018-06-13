@include "tests/Scheduler/Repeat.nut"

function _calcTime() {
    return date();    
}

function _calcError(firedTime, setTime) {
    return (firedTime.time - setTime.time) + (firedTime.usec - setTime.usec) / 1000000.0;
}

function _incrementTime(setTime, interval) {
    setTime.time += math.floor(interval).tointeger();
    setTime.usec += (interval - math.floor(interval).tointeger()) * 1000000;
    return setTime;
}
