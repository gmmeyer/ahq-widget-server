express         = require "express"
app             = express()

config          = require "./config"


module.exports = ->
  ###
  # Static File Compression
  # (should be placed before express.static)
  ###
  app.use express.compress(
    filter: (req, res) ->
      /json|text|javascript|css|svg/.test res.getHeader("Content-Type")
    level: 9
  )

  ###
  # Static Files
  ###
  sixhours = 6 * 60 * 60 * 1000
  app.use express.static(config.paths.root + "/output/"),
    maxAge: if config.server.env is "production" then sixhours else 0
  # Be sure to run this if you use Heroku to serve static files:
  # heroku config:set NODE_ENV=production

  ###
  # No X-Powered-By
  ###
  app.disable("x-powered-by")

  ###
  # Error Handling
  ###
  app.configure "development", ->
    app.use express.errorHandler(
      dumpExceptions: true
      showStack: true
    )

  app.configure "production", ->
    app.use express.errorHandler()

  app.use app.routes

  return app
