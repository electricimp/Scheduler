# Scheduler #

This library provides a simple class to help you manage jobs using one-shot and repeating timers, all of which can be cancelled. It can be used to create multiple jobs that share a single timer &mdash; which may be helpful in agent code, where the number of active timers is limited. This class also allows the user to pass any number of parameters (of any type) to the callbacks that they provide for each job.

**To add this library to your code, please paste its source into your application code**

**Note** This is a beta release. Please file issues in [GitHub](https://github.com/electricimp/Scheduler) to help us improve this library.

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

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *duration* | Float | Yes | The period in seconds before the timer fires |
| *callback* | Function | Yes | The function to run when the timer finishes |
| ... | Any | No | Optional parameters that will be passed into the callback |

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

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *time* | Integer | Yes | The time at which the timer should fire |
| *callback* | Function | Yes | The function to run when the timer fires |
| ... | Any | No | Optional parameters that will be passed into the callback |

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

### repeat(*interval, time, callback[, ...]*) ###

This method creates a new job with a callback that will repeat at the specified interval. To create a timer that repeat's from a specified time, pass a timestamp into the time parameter, otherwise pass `null` into the time parameter.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *interval* | Integer or float | Yes | The interval between timer firings in seconds |
| *time* | Integer or Null | Yes | The time at which the timer should fire, or `null` if timer should trigger based on the interval. |
| *callback* | Function | Yes | The function to run when the timer fires |
| ... | Any | No | Optional parameters that will be passed into the callback |

#### Return Value ####

A Scheduler.Job instance, or an error message if an error was encountered.

#### Example ####

```squirrel
function logMsg(msg, jobName) {
  server.log(jobName + ": " + msg);
}

job1 <- sch.repeat(10, null, logMsg, "Repeats every ten seconds...", "Job 1");

local inFiveSecs = time() + 5;
job2 <- sch.repeatFrom(10, inFiveSecs, logMsg, "Repeats every ten seconds...", "Job 2");
```

## Scheduler.Job Usage ##

You should never call the Scheduler.Job constructor directly. Instead, you should create new jobs (timers) using the Scheduler methods described above.

## Scheduler.Job Methods ##

### now() ###

This method immediately execute the job's callback immediately. It will leave the job in the queue.

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

This method pauses the execution of the job's timer.

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

This method resumes the execution of a paused job's timer. The timer will not reset, it will trigger based on the time remaining when it was paused.

#### Return Value ####

The Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
}

job1 <- sch.set(5, logMsg, "Timer fired");
imp.wakeup(2, job1.pause);
imp.wakeup(10, job1.unpause);
```

### cancel() ###

This method cancels the job. If it is a repeated job it will cancel all repeats as well.

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

This method resets the target job &mdash; ie. it restarts the timer). Optionally, a new duration can be passed in to alter when the timer fires (if it has not done so already).

This method can't be used for jobs set to fire at a specified time. Jobs created with the Scheduler *at()* method or before the first callback of jobs created with the Scheduler *repeat()* method where a time was passed in.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *duration* | Float | No | The optional new timer duration. Default: the originally specified duration |

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
