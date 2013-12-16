module.exports =
  server:
    port:       process.env.PORT || 5002
    env:        process.env.NODE_ENV || "development"

  paths:
    root:       __dirname
