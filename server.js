require("coffee-script/register");
var
  config        = require("./config"),
  app           = require("./express")(),
  watcher       = require("./watcher");

console.log("[" + config.server.env + "] Port: " + config.server.port);
app.listen(config.server.port, function() {
  watcher.init(app)
});
