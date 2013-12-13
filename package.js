Package.describe({
  summary: "A logger for Meteor inspired by log4j and commons-logging."
});

Npm.depends({
  moment: '2.4.0',
  'cli-color': '0.2.3'

});

Package.on_use(function (api, where) {

  api.use(["coffeescript", 'underscore'], ["client", "server"]);

  api.add_files(["src/microevent.coffee"], 'client');
  api.add_files(['src/console.coffee', "src/logger.coffee"], ["client", 'server']);

  if (api.export) //compat with pre-0.6.5
    api.export("Pince", ["server", "client"]);
    api.export("Logger", ["server", "client"]);
    api.export("MicroEvent", ["client"]);
});
