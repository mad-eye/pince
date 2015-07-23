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
* Names can be heirarchally namespaced by separating them with ':'s, like
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
