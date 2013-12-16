# I didn't want to include jQuery in this example, which is huge and overkill
loadJSON = (path, success) ->
  unless typeof success is "function" then return
  xhr = new XMLHttpRequest()
  xhr.onreadystatechange = ->
    unless xhr.readyState is 4 then return
    unless xhr.status is 200 then return
    success(JSON.parse(xhr.responseText))

  xhr.open("GET", path, true)
  xhr.send()

loadJSON "/getip", (response) ->
  if response.ip
    document.getElementById("greeting").innerHTML = "Hello, #{ response.ip }!"
