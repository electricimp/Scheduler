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


// Limitations of imp.wakeup()
// - The timer has only centisecond (0.01s) resolution
// - The imp supports timer durations of up to 2 to the 30
//   centiseconds — ie. 124 days (10713600 sec);
class Scheduler {

    static VERSION  = "0.1.0";
    static ROOT     = getroottable();

    // Start a new timer to trigger after a specific duration
    //
    // Parameters:
    //     dur (float)          the duration of the timer
    //     cb  (function)       the function to run when the timer fires
    //     ... (optional args)  optional params to pass to cb function
    // Return: (integer) a Job instance
    function set(dur, cb, ...) {
        // Add context to vargv array, since we are going to
        // use acall to trigger callback
        vargv.insert(0, ROOT);

        // Create job
        local newJob = Job(_queue, {
            "type" : Job.TYPE_SET,
            "cb"   : cb,
            "args" : vargv,
            "dur"  : dur
        });

        // Add job to queue
        _queue.addJob(newJob);

        // Return job
        return newJob;
    }

    // Start a new timer to trigger at a specific time
    //
    // Parameters:
    //     t  (integer)         the time that the timer should fire
    //     cb (function)        the function to run when the timer fires
    //     ... (optional args)  optional params to pass to cb function
    // Return: (integer) a Job instance
    function at(t, cb, ...) {
        // Add context to vargv array, since we are going to
        // use acall to trigger callback
        vargv.insert(0, ROOT);

        // Create job
        local newJob = Job(_queue, {
            "type" : Job.TYPE_AT,
            "cb"   : cb,
            "args" : vargv,
            "time" : t
        });

        // Add job to queue
        _queue.addJob(newJob);

        // Return job
        return newJob;
    }

    // Start a new timer to trigger repeatedly at a specific interval, starting at a specific time
    //
    // Parameters:
    //     int (integer/float)   the time between executions of the timer
    //     t   (integer/null)    the time for the first execution of the timer, or
    //                           null if timer should trigger immediately
    //     cb (function)         the function to run when the timer fires
    //     ... (optional args)   optional params to pass to cb function
    // Return: (integer) a Job instance
    function repeat(int, t, cb, ...) {
        // Add context to vargv array, since we are going to
        // use acall to trigger callback
        vargv.insert(0, ROOT);

        // Ensure valid timer can be created
        local params = {
            "cb"   : cb,
            "args" : vargv
        };

        // Add repeat interval to params
        params.repeatSec <- (int < 0) ? 0 : int;

        // Add type and parameter used to calculate timer
        // trigger times
        if (t == null) {
            params.type <- Job.TYPE_REPEAT;
            params.dur <- int;
        } else {
            params.type <- Job.TYPE_REPEAT_FROM;
            params.time <- t;
        }

        // Create job
        local newJob = Job(_queue, params);

        // Add job to queue
        _queue.addJob(newJob);

        // Return job
        return newJob;
    }

    // Queue to manage jobs
    // -------------------------------------------------------------------
    _queue = {

        "currentTimer" : null,
        "currentJobId" : null,
        "nextId"       : 1,
        "jobs"         : [],

        // Add a new timer into the correct position in the jobs array
        // Parameters:
        //     newJob (table)       a table representing the new timer
        addJob = function(newJob) {
            // If no jobs are pending add job to queue, and start
            // the timer
            if (jobs.len() == 0) {
                jobs.insert(0, newJob);
                // Update job status
                newJob.status = newJob.STATUS_QUEUED;
                startTimer();
                return;
            }

            // Iterate through the queue backwards looking at where
            // to insert the new job
            for (local i = jobs.len() - 1; i >= 0; i--) {
                if ((jobs[i].triggerAtSec < newJob.triggerAtSec) ||
                    (jobs[i].triggerAtSec == newJob.triggerAtSec &&
                     jobs[i].triggerAtMs < newJob.triggerAtMs)) {
                    jobs.insert(i + 1, newJob);
                    // Update job status
                    newJob.status = newJob.STATUS_QUEUED;
                    break;
                } else if (i == 0) {
                    jobs.insert(0, newJob);
                    // Update job status
                    newJob.status = newJob.STATUS_QUEUED;
                    // Cancel current timer, and set timer for this
                    // job instead
                    startTimer();
                    break;
                }
            }
        },

        // Calls current job's callback. Then removes the current Job
        // from the queue, if it is a repeated job, adds that job back
        // into the queue's
        next = function() {
            if (currentTimer != null) {
                imp.cancelwakeup(currentTimer);
                currentTimer = null;
            }

            if (jobs.len() > 0) {
                // Remove the expired job from queue
                local expJob = jobs.remove(0);
                // Update job status
                expJob.status = expJob.STATUS_EXPIRED;

                // If timer should repeat, add it back to queue
                if (expJob.repeatEveryXSec != null) {
                    // Update trigger times
                    expJob._setTriggersDur(expJob.repeatEveryXSec);
                    // Update job status
                    expJob.status = expJob.STATUS_QUEUED;

                    // Update timer type, effects Job.reset()
                    if (expJob.type == expJob.TYPE_REPEAT_FROM) {
                        expJob.type = expJob.TYPE_REPEAT;
                    }

                    // Add job back into queue
                    addJob(expJob);
                }

                // Trigger callback
                expJob.cb.acall(expJob.args);

                // Trigger next timer in queue
                startTimer();
            }
        },

        // Starts a timer for the first item in the queue if there is
        // one
        startTimer = function() {
            if (jobs.len() > 0) {
                if (currentTimer != null) {
                    imp.cancelwakeup(currentTimer);
                    currentTimer = null;
                }

                local dur = getTimerDuration(jobs[0]);
                currentTimer = imp.wakeup(dur, next.bindenv(this));
                currentJobId = jobs[0].id;
            }
        },

        // Remove specified timer from queue, if it is the current timer
        // queue up the next timer
        // Note: This will cancel all subsequent repeats for repeated
        // timers.
        removeJob = function(id) {
            // Cancel specified timer & remove from queue
            // If this is the current job start timer to
            // trigger next job in the queue
            if (id == currentJobId) {
                imp.cancelwakeup(currentTimer);
                currentTimer = null;
                currentJobId = null;
            }

            foreach (i, job in jobs) {
                if (jobs[i].id == id) {
                    jobs.remove(i);
                    // Update job status
                    job.status = job.STATUS_CANCELED;
                    if (i == 0 && jobs.len() > 0) startTimer();
                }
            }
        },

        getTimerDuration = function(job) {
            // Use job's triggerAtSec and triggerAtMs timestamps to return a duration til that trigger time
            local nowSec, nowMs;
            if (job.IS_AGENT) {
                local now = date();
                nowSec = now.time;
                nowMs = now.usec / 1000;
            } else {
                local now = hardware.millis();
                nowSec = now / 1000;
                nowMs = now % 1000;
            }
            return (job.triggerAtSec - nowSec) + ((job.triggerAtMs - nowMs) * 0.001);
        }
    }

    // Job subclass - manage's each jobs settings
    // -------------------------------------------------------------------
    Job = class {

        static IS_AGENT         = (imp.environment() == ENVIRONMENT_AGENT);
        static TYPE_SET         = "set";
        static TYPE_AT          = "at";
        static TYPE_REPEAT      = "repeat";
        static TYPE_REPEAT_FROM = "repeat from";

        static STATUS_NEW       = "new";
        static STATUS_QUEUED    = "queued";
        static STATUS_EXPIRED   = "expired";
        static STATUS_CANCELED  = "canceled";

        function __statics__() {
            const RESET_ERROR = "Cannot reset job type: %s";
        }

        _q              = null;
        _postPauseDur   = null;

        type            = null;
        id              = null;
        triggerAtSec    = null;
        triggerAtMs     = null;
        dur             = null;
        repeatEveryXSec = null;
        cb              = null;
        args            = null;
        status          = null;

        constructor (q, params) {
            // Set all other params
            if ("type" in params) type = params.type;
            // Set time related params first
            if ("dur" in params) {
                _setTriggersDur(params.dur);
                // Store for use in reset() method
                if (type == TYPE_SET) dur = params.dur;
            }
            if ("time" in params) _setTriggersTime(params.time);
            if ("cb" in params) cb = params.cb;
            if ("args" in params) args = params.args;
            if ("repeatSec" in params) repeatEveryXSec = params.repeatSec;
            // Store pointer to the queue
            _q = q;
            // Calculate id based on current q
            id = _q.nextId++;
            status = STATUS_NEW;
        }

        function getStatus() {
            return status;
        }

        // Note if the timer is a repeating timer this will
        // cancel this and all subsiquent calls
        function cancel() {
            // Remove job from the queue
            _q.removeJob(id);
            return this;
        }

        function now() {
            // Trigger the callback immediately
            // Leave in queue to trigger at scheduled time
            cb.acall(args);
            return this;
        }

        function pause() {
            // Remove job from queue
            _q.removeJob(id);

            // Based on job trigger vals calculate
            // duration left before timer should trigger
            _postPauseDur = _q.getTimerDuration(this);

            return this;
        }

        function unpause() {
            // Use duration left stored when job paused
            // to calculate new tigger time
            if (_setTriggersDur != null) {
                _setTriggersDur(_postPauseDur);
                // Add job back to queue
                _q.addJob(this);
                _postPauseDur = null;
            }
            return this;
        }

        function reset(newDur = null) {
            // Check timer type, if valid type update queue and trigger times
            if (type == TYPE_AT || type == TYPE_REPEAT_FROM) {
                throw format(RESET_ERROR, type);
            }

            // Sync store duration/repeatEveryXSec with new duration
            // Note: Only TYPE_SET has stored duration
            if (type == TYPE_SET) {
                (newDur == null) ? newDur = dur : dur = newDur;
            } else if (type == TYPE_REPEAT) {
                (newDur == null) ? newDur = repeatEveryXSec : repeatEveryXSec = newDur;
            }

            // Update Job's trigger times
            _setTriggersDur(newDur);

            // Remove timer from q
            _q.removeJob(id);

            // Add job back to queue
            _q.addJob(this);

            return this;
        }

        function _setTriggersTime(ts) {
            // Ensure timestamp is what we expect
            if (typeof ts == "float") ts = ts.tointeger();
            local now = time();
            if (ts < now) ts = now;

            // Note integer timestamps on imp have second
            // granularity
            if (IS_AGENT) {
                // Agent uses date() to set trigger time
                triggerAtSec = ts;
                triggerAtMs  = 0;
            } else {
                // Device uses time since boot (in ms), to
                // get sub second granularity, so convert
                // epoch timestamp.

                // Get current ms timestamp
                local msBoot = hardware.millis();
                // Calculate duration of timer based on
                // current epoch time
                local durSec = ts - now;

                // Calculate when timer should fire based
                // on hardware.millis. Since agent has to
                // split second and ms times, do that on
                // the device.
                triggerAtSec = (msBoot / 1000) + durSec;
                triggerAtMs  = msBoot % 1000;
            }
        }

        function _setTriggersDur(dur) {
            // Ensure timestamp is what we expect
            if (dur < 0) dur = 0;

            // Calculate time when job should trigger at
            // Value is split into 2 integer values (second, ms)
            if (IS_AGENT) {
                local now = date();
                triggerAtSec = (dur / 1) + now.time;
                triggerAtMs  = (dur % 1) + now.usec / 1000;
            } else {
                local now = hardware.millis();
                triggerAtSec = (dur / 1) + now / 1000;
                triggerAtMs  = (dur % 1) + now % 1000;
            }
        }
    }

}