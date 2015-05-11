http = require 'http'

{fold1} = require 'prelude-ls'

default-port = 6767
default-ssl-port = 16167
default-protcol = 'http'
default-content-type = 'text/plain'

create-server = (port=default-port, protocol=default-protcol) ->
  server = http.createServer (req, res) ->
    server.emit req.url, req, res

  server.port = port
  server.protocol = protocol
  server.url = "#{protocol}://localhost:#{port}"
  return server

create-get-response = (text, content-type=default-content-type) ->
  response-fn = (req, res) ->
    res.writeHead 200, 'content-type': content-type
    res.write text
    res.end!

create-chunk-response = (chunks, content-type=default-content-type) ->
  response-fn = (req, res) ->
    res.writeHead 200, 'content-type': content-type
    for chunk in chunks then res.write chunk
    res.end!

create-post-validator = (text, expect-fn) ->
  response-fn = (req, res) ->
    data = ''
    req.on 'data', (_) -> data += _
    req.on 'end', ->
      res.writeHead 200, 'content-type': 'text/plain'
      res.write data
      res.end()
      expect-fn data

module.exports =
  port: default-port
  sslPort: default-ssl-port
  createServer: create-server
  createGetResponse: create-get-response
  createChunkResponse: create-chunk-response
  createPostValidator: create-post-validator
