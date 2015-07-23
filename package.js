Package.describe({
  summary: "A logger for Meteor inspired by log4j and commons-logging.",
  version: "0.0.8",
  name: "jag:pince",
  git: "https://github.com/mad-eye/pince.git",
});

Npm.depends({
  "cli-color": "0.2.3"
});

Package.onUse(function (api, where) {
  api.use('coffeescript');
  api.use('momentjs:moment@2.10.3');

  api.export('Logger');
  api.add_files('dist/pince-meteor-browser.coffee', 'client');
  api.add_files('dist/pince-meteor-server.coffee', 'server');
});
