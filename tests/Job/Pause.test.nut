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

class PauseAndUnpauseTestCase extends ImpTestCase {

    _scheduler = null;

    function setUp() {
        _scheduler = Scheduler();
    }

    function testPauseAndUnpause() {
        local dur = 3;
        local fired = false;
        local job1 = _scheduler.set(dur, function() {fired = true;}.bindenv(this));

        return Promise(function(resolve,reject) {
            job1.pause();

            try {
                imp.wakeup(dur + 2, function() {
                    this.assertTrue(!fired, "Job fired despite being paused");
                    job1.unpause();
                    imp.wakeup(dur + 2, function() {
                        this.assertTrue(fired, "Job didn't fire despite being unpaused");
                        resolve();
                    }.bindenv(this));
                }.bindenv(this));
            } catch(e) {
                reject(e);
            }

        }.bindenv(this));
    }

}
