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

// Helper functions for Scheduler tests (except reapeat from)

function _isAgent() {
    return (imp.environment() == ENVIRONMENT_AGENT);
}

// Used in Set, Repeat, At
function _calcTime() {
    return (_isAgent()) ? time() : hardware.millis() / 1000.0;
}

// Used in At, Set, Repeat
function _calcDate() {
    return (_isAgent()) ? date() : hardware.millis() / 1000.0;
}

// Used in Set, Repeat, At, Repeat from
function _calcError(firedTime, setTime) {
    if (_isAgent()) {
        return ((firedTime.time - setTime.time) + (firedTime.usec - setTime.usec) / 1000000.0);
    } else {
        if (typeof firedTime == "integer" || typeof firedTime == "float") {
            return firedTime - setTime;
        } else if (typeof firedTime == "table") {
            return firedTime.time - setTime;
        }
    }
}

// Used in Repeat
function _incrementTime(setTime, interval) {
    if (_isAgent()) {
        setTime.time += math.floor(interval).tointeger();
        setTime.usec += (interval - math.floor(interval).tointeger()) * 1000000;
        return setTime;
    } else {
        return setTime += interval;
    }
}


