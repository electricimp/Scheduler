//MIT License
//
//Copyright 2018 Electric Imp
//
//SPDX-License-Identifier: MIT
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be
//included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
//EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
//OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//OTHER DEALINGS IN THE SOFTWARE.

@include "tests/global.nut";

// Repeat from helpers differ from helper class include them here instead
// HELPERS
// ------------------------------------------------------------
function _isAgent() {
    return (imp.environment() == ENVIRONMENT_AGENT);
}

function _calcTime() {
    return (_isAgent()) ? date() : time();
}

function _calcTimeToFire() {
    return time() + 1;
}

function _calcStartTime(offset) {
    return (_isAgent()) ? (time() + offset) : offset;
}

function _calcError(firedTime, timeToFire, setTime) {
    if (_isAgent()) {
        return ((firedTime.time - setTime.time) + (firedTime.usec - setTime.usec) / 1000000.0)
    } else {
        return firedTime - timeToFire;
    }
}

function _testRepeatFrom(timeToFire, interval) {
    return Promise(function(resolve, reject) {
        local first = true;
        local checker;
        if (!_isAgent()) timeToFire += time();

        local testJob;
        testJob = _scheduler.repeat(interval, timeToFire, function() {
            local firedDate = date();
            local firedTime = firedDate.time;
            local timeError;

            if (first) {
                timeError = firedTime - timeToFire;
            } else {
                if (_isAgent()) {
                    timeError = ((firedTime - checker.time) + (firedDate.usec - checker.usec) / 1000000.0) - interval;
                } else {
                    timeError = firedTime - checker;
                }
            }

            try {
                this.assertTrue((timeError <= SCHEDULER_ACCEPTED_ERROR && timeError >= (-1 * SCHEDULER_ACCEPTED_ERROR)), "Timer fired with error of: " + timeError);

                if (first) {
                    first = false;
                    checker = (_isAgent()) ? date() : time() + interval;
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

// ------------------------------------------------------------

// Tests
class RepeatFromTestCase extends ImpTestCase {

    _scheduler = null;

    function setUp() {
        _scheduler = Scheduler();
    }

    function testRepeatFromPositive() {
        return _testRepeatFrom(_calcStartTime(2), 3);
    }

    function testRepeatFromDecimal() {
        return _testRepeatFrom(_calcStartTime(2), 3.2);
    }

    function testRepeatFromNow() {
        return _testRepeatFrom(_calcStartTime(0), 3);
    }

    function testRepeatFromNegative() {
        return Promise(function(resolve, reject) {
            local first = true;
            local setTime = _calcTime();
            local timeToFire = time() + 1;

            local interval = -3;
            local testJob;
            testJob = _scheduler.repeat(interval, timeToFire, function() {
                local firedTime = _calcTime();
                local timeError = _calcError(firedTime, timeToFire, setTime);

                try {
                    this.assertTrue((timeError < SCHEDULER_ACCEPTED_ERROR && timeError > (-1 * SCHEDULER_ACCEPTED_ERROR)), "Timer fired with error of: " + timeError);

                    if (first) {
                        first = false;
                        timeToFire = time();
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

    function testRepeatFromWithParams() {
        return Promise(function(resolve, reject) {
            local job1 = null;
            job1 = _scheduler.repeat(0, time(), function(testInt) {
                try {
                    this.assertTrue(testInt == 5, "Parameter not passed correctly to callback");
                    resolve();
                } catch (e) {
                    reject(e);
                }
                job1.cancel();
            }.bindenv(this), 5);
        }.bindenv(this));
    }

}
