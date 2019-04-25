# Scheduler #

This library provides a simple class to help you manage jobs using one-shot and repeating timers, all of which can be cancelled. It can be used to create multiple jobs that share a single timer &mdash; which may be helpful in agent code, where the number of active timers is limited. This class also allows the user to pass any number of parameters (of any type) to the callbacks that they provide for each job.

**To add this library, add the following lines to the top of your code:**

```
#require "Scheduler.lib.nut:0.1.0"
```

**Note** This is a beta release. Please file issues in [GitHub](https://github.com/electricimp/Scheduler) to help us improve this library.

![Build Status](https://cse-ci.electricimp.com/app/rest/builds/buildType:(id:Scheduler_BuildAndTest)/statusIcon)

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

This method creates a new job with a callback to execute at the specified time. The time should be provided as an integer representing the number of seconds that have elapsed since midnight on 1 January 1970.

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

This method creates a new job with a callback that will repeat at the specified interval. To create a timer that repeat's from a specified time pass in an integer representing the number of seconds that have elapsed since midnight on 1 January 1970, otherwise pass `null` into the time parameter.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *interval* | Integer or float | Yes | The interval between timer firings in seconds |
| *time* | Integer or Null | Yes | The time at which the timer should fire, or `null` if timer should trigger based on the interval |
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
job2 <- sch.repeat(10, inFiveSecs, logMsg, "Repeats every ten seconds...", "Job 2");
```

## Scheduler.Job Usage ##

You should never call the Scheduler.Job constructor directly. Instead, you should create new jobs (timers) using the Scheduler methods described above.

## Scheduler.Job Methods ##

### now() ###

This method immediately executes the job's callback. If job repeats, it will be rescheduled to fire based on the repeat interval, otherwise the job will be removed from the queue.

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

### cancel() ###

This method cancels the job. If it is a repeated job it will cancel all repeats.

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

### getStatus() ###

This method returns the current status of a Job.

#### Parameters ####

None.

#### Return Value ####

A job status constant.

| Constant | Value | Description |
| --- | --- | --- |
| *STATUS_NEW* | "new" | Job has been created, but not placed in the queue |
| *STATUS_QUEUED* | "queued" | Job is in the queue |
| *STATUS_EXPIRED* | "expired" | Job has tiggered it's callback, and is no longer in the queue |
| *STATUS_CANCELED* | "canceled" | Job has been deleted from the queue |

#### Example ####

```squirrel
function logMsg(msg) {
  server.log(msg);
  if (job1.getStatus() == job1.STATUS_EXPIRED) {
    server.log("Job 1 complete.");
    job1 <- null;
  }
}

// Set a job that will fire in 10s
job1 <- sch.set(10, logMsg, "Timer fired");
if (job1.getStatus() == job1.STATUS_QUEUED) {
    server.log("Job 1 scheduled.");
}
```

## License ##

The Scheduler library is licensed under the [MIT License](LICENSE).
