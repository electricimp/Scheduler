function _calcTime() {
    return date();
}

function _calcTimeToFire() {
    return time() + 1;
}

function _calcStartTime(offset) {
    return time() + offset;    
}

function _calcError(firedTime, timeToFire, setTime) {
    return ((firedTime.time - setTime.time) + (firedTime.usec - setTime.usec) / 1000000.0);
}

function _testRepeatFrom(timeToFire, interval) {
    return Promise(function(resolve, reject) {
        local first = true;
        local setDate;

        local testJob;
        testJob = _scheduler.repeatFrom(timeToFire, interval, function() {
            local firedDate = date();
            local timeError;
            if (first) {
                timeError = firedDate.time - timeToFire;
            } else {
                timeError = ((firedDate.time - setDate.time) + (firedDate.usec - setDate.usec) / 1000000.0) - interval;
            }

            try {
                this.assertTrue((timeError <= SCHEDULER_ACCEPTED_ERROR && timeError >= (-1 * SCHEDULER_ACCEPTED_ERROR)), "Timer fired with error of: " + timeError);

                if (first) {
                    first = false;
                    setDate = date();
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
