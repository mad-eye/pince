Pince
=====

Pince is a lightweight logger that combines some of the best
properties of log4j and node.  It's equally usable in Node, (most)
browsers, and Meteor (client and server).

It was developed for [MadEye](https://madeye.io).

Features:

* Log levels: error, warn, info, debug, trace
* Dynamically change the log level on the client.
* Change the log level with no code changes on the server.
* Logging is very lightweight when there's nothing listening to it.
* Each logger has a name -- you can set levels individually by name!
* Names can be hierarchically namespaced by separating them with ':'s, like
  `myLibrary:aModule:thisObject`.
* Set log levels by any level of the namespace hierarcy!


Installation (Node.js)
----------------------
To install, `npm install pince`.

In any file you wish to make a logger, require it via
`Logger = require('pince');`

Installation (Meteor)
---------------------
To install, just `meteor add jag:pince`.  The global `Logger` symbol will be
there waiting for you.

By default, on the server Meteor will prepend a string to logs that includes
a timestamp (amongst other things).  To silence Meteor's prefix, run meteor
with the `--raw-logs` flag: `meteor --raw-logs`.

Installation (Browser)
----------------------
Just source `pince-browser.js`.

Usage
----------

Set the log level:
```javascript
//Default is info
Logger.setLevel('trace');
```

Make a new logger:
```javascript
var log = new Logger('router');
log.info("Routing.");
//2013-10-31 11:29:36.097 info:  [router]  Routing.
log.trace("Setting up routes...");
//2013-10-31 11:29:36.101 trace:  [router]  Setting up routes...
```

Set individual levels:
```javascript
Logger.setLevel('info');
Logger.setLevel('controller', 'trace');
var routerLog = new Logger('router');
var controllerLog = new Logger('controller');

routerLog.trace("Can't hear me!");
//Nothing
controllerLog.trace("Can hear me.");
//2013-10-31 11:31:21.906 trace:  [controller]  Can hear me.

Logger.setLevels({router:'debug', controller:'warn'});
routerLog.info("Finally! Someone is listening to me.");
//2013-10-31 11:32:48.374 info:  [router]  Finally! Someone is listening to me.
controllerLog.info("Hello? Hello??");
//Nothing
```

Hierarchically name and set levels:
```javascript
var routerLog = new Logger('myPackage:router');
var controllerLog = new Logger('myPackage:controller');
Logger.setLevel('myPackage', 'info');
Logger.setLevel('myPackage:controller', 'debug');

routerLog.info('You can see this.');
routerLog.debug('You cannot see this; myPackage level is set to info.');
controllerLog.debug('You can see this, myPackage:controller level is set to debug.');
```

Control the output formatting:
```javascript
var log = new Logger('router');
log.info('A message.');
//2013-10-31 11:32:48.374 info:  [router]  A message.
Logger.setFormat('%N:%L [%T] %M');
log.info('A message.');
//router:info [2013-10-31 11:32:48.374] A message.
Logger.setDateFormat('YYYY_MM_DD_HH_mm_ss');
log.info('A message.');
//router:info [2013_10_31_11_32_48] A message.
```

To control the formatting, use `Logger.setFormat(str)` and
`Logger.setDateFormat(str)`.  The former controls the overall format, and includes the escape characters:
  * `%T` The timestamp string (as controlled by `setDateFormat()`).
  * `%L` The logging level, eg `info`.
  * `%N` The name of the logger, eg `myPackage:router`.
  * `%M` The message to log.

In addition, you can control the appearance of the timestamp.  The timestamp format string has the special sequences:
  * `YYYY` The full 4-digit date.
  * `MM` The 2-digit month (1-12).
  * `DD` The 2-digit date (1-31).
  * `HH` The 2-digit hour (00-23).
  * `mm` The 2-digit minute (00-59).
  * `ss` The 2-digit second (00-59).
  * `SSS` The 3-digit millisecond (000-999).
