snockets        = new (require "snockets")
config          = require "./config"
fs              = require "fs"
wrench          = require "wrench"
rimraf          = require "rimraf"
chokidar        = require "chokidar"
jade            = require "jade"
stylus          = require "stylus"
nib             = require "nib"
CleanCSS        = require "clean-css"

widgets_path = config.paths.root + "/widgets/"

generate = (widget) ->
  _w = "[#{widget}]"
  _path = widgets_path + widget

  console.log "==="
  console.log "#{_w} Packing widget"

  if fs.existsSync("#{ _path }/widget.coffee")
    console.log "#{_w} Generating JS"
    js = snockets.getConcatenation "#{ _path }/widget.coffee", { minify: true, async: false }
  else
    console.log "#{_w} No JS to generate"
    js = ""

  if fs.existsSync("#{ _path }/widget.styl")
    console.log "#{_w} Generating and minifying CSS"
    css = null;
    stylus(
      fs.readFileSync("#{ _path }/widget.styl")
      .toString()
    ).use(nib())
    .set("include css", true)
    .set('filename', "#{ _path }/widget.styl")
    .set("compress", true)
    .render((err, _css) ->
      if err
        console.error err
      css = new CleanCSS().minify(_css)
    )
  else
    console.log "#{_w} No CSS to generate/minify"
    css = ""

  if fs.existsSync("#{ _path }/widget.jade")
    console.log "#{_w} Generating HTML"
    html = jade.renderFile "#{ _path }/widget.jade", {
      js: js
      css: css
      NODE_ENV: config.server.env
    }
  else
    console.log "#{_w} No HTML"
    html = null


  if html isnt null
    console.log "#{_w} Saving HTML"
    fs.writeFileSync(config.paths.root + "/output/" + widget + ".html", html)
  else
    console.log "#{_w} Nothing to save"


  if fs.existsSync("#{ _path }/assets") and fs.lstatSync("#{ _path }/assets").isDirectory()
    console.log "#{_w} Copying Assets to ./output"
    wrench.copyDirSyncRecursive("#{ _path }/assets", config.paths.root + "/output/" + widget)
  else
    console.log "#{_w} No assets to copy to ./output"

  console.log "==="

exports.init = (app) ->
  console.log "Deleting ./output folder"
  rimraf "#{ config.paths.root }/output/", (err) ->
    if err then return console.log err
    fs.mkdirSync "#{ config.paths.root }/output/"

    widgets = []
    fs.readdir widgets_path, (err, files) ->
      if err then return console.log err

      for file in files
        if fs.statSync(widgets_path + file).isDirectory()
          widgets.push(file)

      for i, widget of widgets
        # Run the widget's server-side code if present
        if fs.existsSync("#{ widgets_path }#{ widget }/server.coffee")
          console.log "[#{ widget }] Running server.coffee"
          require("#{ widgets_path }#{ widget }/server.coffee")(app)

        generate(widget)

      chokidar.watch(widgets_path, { persistent: true }).on("change", (path) ->
        _widget = path.split("\\")[path.split("\\").indexOf("widgets")+1]
        isWidget = widgets.indexOf(_widget) isnt -1

        generate(_widget) if isWidget
      )
      # assume 404 since no middleware responded
      # Must come after all other routes being set
      app.use (req, res, next) ->
        res.status(404).jsonp {
          error:
            404: "Not Found"
        }
