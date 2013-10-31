MadEye Logger
=============

MadEye Logger is a lightweight logger that combines some of the best
properties of log4j and node.  It's equally usable in Node, (most)
browsers, and Meteor (client and server).

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

Right now, just clone this repo into your `node_modules` directory.
Coming soon, `npm install madeye-logger`.

In any file you wish to make a logger, require it via
`Logger = require('madeye-logger');`

Installation (Meteor)
---------------------
Right now, just clien this repo into your `packages` directory and
type `meteor add logger`.
Coming soon, `mrt add logger`.

Quickstart
----------

Set the log level:
```javascript
//Default is info
Logger.setLevel('trace');
```

Make a new logger:
```javascript
log = new Logger('router');
log.info("Routing.");
//2013-10-31 11:29:36.097 info:  [router]  Routing.
log.trace("Setting up routes...");
//2013-10-31 11:29:36.101 trace:  [router]  Routing.
```

Set individual levels:
```javascript
Logger.setLevel('info');
Logger.setLevel('controller', 'trace');
routerLog = new Logger('router');
controllerLog = new Logger('controller');

routerLog.trace("Can't hear me!");
//Nothing
controllerLog.trace("Can hear me."):
//2013-10-31 11:31:21.906 trace:  [controller]  Can hear me.

Logger.setLevels({router:'debug', controller:'warn'});
routerLog.info("Finally! Someone is listening to me.");
//2013-10-31 11:32:48.374 info:  [router]  Finally! Someone is listening to me.
controllerLog.info("Hello? Hello??");
//Nothing
```
 
