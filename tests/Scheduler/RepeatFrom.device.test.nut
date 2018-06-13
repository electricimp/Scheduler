function _calcTime() {
    return time();
}

function _calcTimeToFire() {
    return time() + 1;
}

function _calcStartTime(offset) {
    return offset;    
}

function _calcError(firedTime, timeToFire, setTime) {
    return firedTime - timeToFire;
}

function _testRepeatFrom(dur, interval) {
    return Promise(function(resolve, reject) {
        local first = true;
        local timeToRepeat;
        local setTime = time();

        local testJob;
        testJob = _scheduler.repeatFrom(setTime + dur, interval, function() {
            local firedTime = time();
            local timeError;
            if (first) {
                timeError = firedTime - (setTime + dur);
            } else {
                timeError = firedTime - timeToRepeat;
            }

            try {
                this.assertTrue((timeError <= SCHEDULER_ACCEPTED_ERROR && timeError >= (-1 * SCHEDULER_ACCEPTED_ERROR)), "Timer fired with error of: " + timeError);

                if (first) {
                    first = false;
                    timeToRepeat = time() + interval;
                } else {
                    testJob.cancel();
                    resolve();
                }
            } catch (e) {
                reject(e);
            }
        }.bindenv(this));
    }.bindenv(this));
}
