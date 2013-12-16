###
This is code that will run on the server, not on the client.

If, for example, you wanted to get something from a non-HTTPS API, you would
need to handle that here.
###


init = (app) ->
  app.get "/getip", getClientIp

getClientIp = (req, res) ->
  # Amazon EC2 / Heroku workaround to get real client IP
  forwardedIpsStr = req.header("x-forwarded-for")
  if forwardedIpsStr

    # 'x-forwarded-for' header may return multiple IP addresses in the format:
    # "client IP, proxy 1 IP, proxy 2 IP" so take the the first one
    forwardedIps = forwardedIpsStr.split(",")
    ipAddress = forwardedIps[0]

  # Ensure getting client IP address still works in development
  ipAddress = req.connection.remoteAddress unless ipAddress

  # Output to client
  res.json {
    ip: ipAddress
  }

# Export the init function
module.exports = init
