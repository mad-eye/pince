Package.describe({
  summary: "A logger for Meteor inspired by log4j and commons-logging.",
  version: "0.0.6",
  name: "jag:pince",
  git: "https://github.com/mad-eye/pince.git",
});

Npm.depends({
  "cli-color": "0.2.3"

});

Package.onUse(function (api, where) {
  api.versionsFrom('0.9.0');

  api.use('coffeescript');
  api.use('momentjs:moment');

  api.add_files(['src/microevent.coffee', 'src/browserOutput.coffee'], 'client');
  api.add_files(['src/consoleOutput.coffee'], 'server');
  api.add_files(['src/logger.coffee'], ['client', 'server']);

  api.export("Pince");
  api.export("Logger");
  api.export("MicroEvent", "client");
});
