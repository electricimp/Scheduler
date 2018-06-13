# Scheduler #

A simple class to manage jobs with one-off and interval timers all of which can be cancelled.
Can be used to create multiple jobs that actually share a single timer which may be helpful on
the agent where the number of active timers is limited. This class also allows the user to pass
parameters to the callbacks they provide for each job.

To add this library to your model, add the following lines to
the top of your agent code:

```
#require "Scheduler.lib.nut:1.0.0"
```

## Scheduler Usage ##

This class manages all jobs. Each method for creating a job will return a new Scheduler.Job instance.

### Constructor: Scheduler ###

The constructor for Scheduler takes no parameters.

#### Example ####

```squirrel
sch <- Scheduler();
```

## Scheduler Methods ##

### set(*\_duration, \_callback[, ...]*) ###

Starts a new timer that executes the callback after the specified duration.

#### Parameters ####

Parameter         | Type           | Required       | Default        | Description
----------------- | -------------- | -------------- | -------------- | ----------------
\_duration        | float          | Yes            | N/A            | The duration of the timer in seconds
\_callback        | function       | Yes            | N/A            | The function to run when the timer finishes
...               | any            | No             | N/A            | Optional parameters that will be passed to the callback

#### Return Value ####

A Scheduler.Job instance.

#### Example ####
```
function logMsg(msg) {
    server.log(msg);
}

job1 <- sch.set(5, logMsg, "Timer fired");
```

### at(*\_time, \_callback[, ...]*) ###

Creates a new job with a callback to execute at a specified time. The time can either be provided as an integer (do NOT provide a float) representing the number of seconds that have elapsed since midnight on 1 January 1970 OR as a string in the following format: "January 01, 2017 12:30 PM".

#### Parameters ####

Parameter         | Type           | Required       | Default        | Description
----------------- | -------------- | -------------- | -------------- | ----------------
\_time            | integer/string | Yes            | N/A            | The time when the timer should end
\_callback        | function       | Yes            | N/A            | The function to run when the timer finishes
...               | any            | No             | N/A            | Optional parameters that will be passed to the callback

#### Return Value ####

A Scheduler.Job instance.

#### Example ####
```
function logMsg(msg) {
    server.log(msg);
}

in5Sec <- time() + 5;
job1 <- sch.at(in5Sec, logMsg, "Timer fired");
```

### repeat(*\_interval, \_callback[, ...]*) ###

Creates a new job with a callback that will repeat at the specified interval.

#### Parameters ####

Parameter         | Type           | Required       | Default        | Description
----------------- | -------------- | -------------- | -------------- | ----------------
\_interval        | float          | Yes            | N/A            | The interval between executions of the timer in seconds
\_callback        | function       | Yes            | N/A            | The function to run when the timer finishes
...               | any            | No             | N/A            | Optional parameters that will be passed to the callback

#### Return Value ####

A Scheduler.Job instance, or an error message if an error was encountered.

#### Example ####
```
function logMsg(msg) {
    server.log(msg);
}

job1 <- sch.repeat(10, logMsg, "Repeats every 10s...");
```

### repeatFrom(*\_time, \_interval, \_callback[, ...]*) ###

Creates a new job with a callback to execute at the specified time as an integer or string (do NOT provide a float) and then repeat at the specified interval after that. Returns the new job.

#### Parameters ####

Parameter         | Type           | Required       | Default        | Description
----------------- | -------------- | -------------- | -------------- | ----------------
\_time            | integer/string | Yes            | N/A            | The time when the timer should end
\_interval        | float          | Yes            | N/A            | The interval between executions of the timer in seconds
\_callback        | function       | Yes            | N/A            | The function to run when the timer finishes
...               | any            | No             | N/A            | Optional parameters that will be passed to the callback

#### Return Value ####

A Scheduler.Job instance.

#### Example ####
```
function logMsg(msg) {
    server.log(msg);
}

in5Sec <- time() + 5;
job1 <- sch.repeatFrom(in5Sec, 10, logMsg, "Repeats every 10s...");
```

## Scheduler.Job ##

You should never call the Scheduler.Job constructor directly, instead, you should create new jobs (timers) using Scheduler methods.

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

Unpause the execution of the job's timer.

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

### reset(*[rstDur]*) ###

Resets this job (i.e. restart the timer). Optionally, a different duration to the original can be passed to this method.

This method can't be used for jobs created with the Scheduler `at()` method or during the first timer of jobs created with the Scheduler `repeatFrom()` method, however it can be used for Scheduler `repeatFrom()` jobs after they've fired the first time.

#### Parameters ####

Parameter         | Type           | Required       | Default           | Description
----------------- | -------------- | -------------- | ----------------- | ----------------
rstDur            | float          | No             | original duration | The optional new timer duration

#### Return Value ####

The Scheduler.Job instance.

#### Example ####

```squirrel
function logMsg(msg) {
    server.log(msg);
}

job1 <- sch.set(10, logMsg, "Timer fired");
job1.reset(5);
```

# License

The Scheduler library is licensed under the [MIT License](LICENSE).
