# Scheduler #

This library provides a simple class to help you manage jobs using one-shot and repeating timers all of which can be cancelled. It can be used to create multiple jobs that share a single timer &mdash; which may be helpful in agent code, where the number of active timers is limited. This class also allows the user to pass parameters to the callbacks that they provide for each job.

**To use this library, add** `#require "Scheduler.lib.nut:1.0.0"` **to the top of your device or agent code.**

## Scheduler Usage ##

This class manages all jobs. Each method for creating a job will return a new Scheduler.Job instance.

### Constructor: Scheduler() ###

The constructor has no parameters.

#### Example ####

```squirrel
sch <- Scheduler();
```

## Scheduler Methods ##

### set(*duration, callback[, ...]*) ###

This method starts a new timer which executes the supplied callback after the specified duration.

#### Parameters ####

Parameter | Type | Required | Description
--- | --- | --- | ---
*duration* | Float | Yes | The duration of the timer in seconds
*callback* | Function | Yes | The function to run when the timer finishes
... | Any | No | Optional parameters that will be passed into the callback

#### Return Value ####

A Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(message) {
  server.log(message);
}

job1 <- sch.set(5, logMsg, "Timer fired");
```

### at(*time, callback[, ...]*) ###

This method creates a new job with a callback to execute at the specified time. The time can either be provided as an integer representing the number of seconds that have elapsed since midnight on 1 January 1970, or as a string in the following format: `"January 01, 2017 12:30 PM"`.

#### Parameters ####

Parameter | Type | Required | Description
--- | --- | --- | ---
*time* | Integer or string | Yes | The time when the timer should end
*callback* | Function | Yes | The function to run when the timer finishes
... | Any | No | Optional parameters that will be passed into the callback

#### Return Value ####

A Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

local inFiveSecs = time() + 5;
job1 <- sch.at(inFiveSecs, logMsg, "Timer fired");
```

### repeat(*interval, callback[, ...]*) ###

This method creates a new job with a callback that will repeat at the specified interval.

#### Parameters ####

Parameter | Type | Required | Description
--- | --- | --- | ---
*interval* | Integer or float | Yes | The interval between executions of the timer in seconds
*callback* | Function | Yes | The function to run when the timer finishes
... | Any | No | Optional parameters that will be passed into the callback

#### Return Value ####

A Scheduler.Job instance, or an error message if an error was encountered.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

job1 <- sch.repeat(10, logMsg, "Repeats every ten seconds...");
```

### repeatFrom(*time, interval, callback[, ...]*) ###

This method reates a new job with a callback to execute at the specified time, and then repeat at the specified interval.

#### Parameters ####

Parameter | Type | Required | Description
--- | --- | --- | ---
\_time | Integer or string | Yes | The time when the timer should end
\_interval | Integer or float | Yes | The interval between executions of the timer in seconds
\_callback | Function | Yes | The function to run when the timer finishes
... | Any | No | Optional parameters that will be passed into the callback

#### Return Value ####

A Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

local inFiveSecs = time() + 5;
job1 <- sch.repeatFrom(inFiveSecs, 10, logMsg, "Repeats every ten seconds...");
```

## Scheduler.Job Usage ##

You should never call the Scheduler.Job constructor directly. Instead, you should create new jobs (timers) using the Scheduler methods described above.

## Scheduler.Job Methods ##

### now() ###

Immediately execute this job.

#### Return Value ####

The Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

job1 <- sch.set(20, logMsg, "Timer fired");
job1.now();
```

### pause() ###

Pause the execution of the job's timer.

#### Return Value ####

The Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

job1 <- sch.set(5, logMsg, "Timer fired");
job1.pause();
```

### unpause() ###

Resume the execution of the job's timer.

#### Return Value ####

The Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

job1 <- sch.set(5, logMsg, "Timer fired");
job1.pause();

imp.wakeup(10, job1.unpause);
```

### cancel() ###

Cancel this job.

#### Return Value ####

The Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

job1 <- sch.set(5, logMsg, "Timer fired");
job1.cancel();
```

### reset(*[duration]*) ###

Resets this job (i.e. restart the timer). Optionally, a different duration to the original can be passed to this method.

This method can't be used for jobs created with the Scheduler `at()` method or during the first timer of jobs created with the Scheduler `repeatFrom()` method, however it can be used for Scheduler `repeatFrom()` jobs after they've fired the first time.

#### Parameters ####

Parameter | Type | Required | Description
--- | --- | --- | ---
duration | float | No | The optional new timer duration (Default: the originally specified duration)

#### Return Value ####

The Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

// Set a job that will fire in 10s
job1 <- sch.set(10, logMsg, "Timer fired");

// Change the job to fire in 5s
job1.reset(5);
```

## License ##

The Scheduler library is licensed under the [MIT License](LICENSE).
