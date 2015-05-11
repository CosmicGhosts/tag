require! {
  './feature-spec-helper': {
    tag, o, x, desc, cont
    expect, sinon, testServer
  }
}

lambda = 'λ'
server = testServer.createServer!

add-route-response = (route, response-fn) ->
  server.on route, response-fn
  uri = "#{server.url}#{route}"
  {uri}

make-equality-fn = (op, expected-body, done) ->
  (err, res, body) ->
    expect(err).to[op] null
    expect(res.body).to[op] expected-body
    expect(body).to[op] expected-body
    done err

equal = make-equality-fn.bind null, 'eq'
deep-equal = make-equality-fn.bind null, 'eql'

desc 'Feature: Request Body', ->
  before (done) ->
    server.listen testServer.port, -> done!

  after (done) ->
    server.removeAllListeners!
    server.close -> done!

  # Get Requests

  cont 'When the server responds with a string', ->
    expected-body = 'test'
    response-fn = testServer.createGetResponse expected-body
    {uri} = add-route-response '/testGet', response-fn
    options = uri: uri

    o 'Return the string', (done) ->
      tag options, equal(expected-body, done)

  cont 'When the server responds with a buffer', ->
    cont 'And the request asked for default encoding', ->
      expected-body = 'test'
      response-fn = testServer.createGetResponse new Buffer expected-body
      {uri} = add-route-response '/testGetBufferDefault', response-fn
      options = uri: uri

      o 'Return the default encoded buffer', (done) ->
        tag options, equal(expected-body, done)

    cont 'And the request asked for no encoding', ->
      expected-body = new Buffer 'test'
      response-fn = testServer.createGetResponse expected-body
      {uri} = add-route-response '/testGetBufferNoEncoding', response-fn
      options = uri: uri, encoding: null

      o 'Return the buffer', (done) ->
        tag options, deep-equal(expected-body, done)

    cont 'And the request asked for HEX encoding', ->
      expected-body = '74657374'
      response-fn = testServer.createGetResponse new Buffer expected-body, 'hex'
      {uri} = add-route-response '/testGetBufferHex', response-fn
      options = uri: uri, encoding: 'hex'

      o 'Return the HEX encoded buffer', (done) ->
        tag options, equal(expected-body, done)

    cont 'And the request asked for UTF8 encoding', ->
      expected-body = 'test'
      response-fn = testServer.createGetResponse new Buffer [116, 101, 115, 116]
      {uri} = add-route-response '/testGetBufferUTF8', response-fn
      options = uri: uri, encoding: 'utf8'

      o 'Return the UTF8 encoded buffer', (done) ->
        tag options, equal(expected-body, done)

  cont 'When the server responds with chunked data', ->
    chunks = ['t', 'e', 's', 't']
    expected-body = chunks.join ''
    response-fn = testServer.createChunkResponse expected-body
    {uri} = add-route-response '/testGetChunk', response-fn
    options = uri: uri

    o 'Return the complete data', (done) ->
      tag options, equal(expected-body, done)

  cont 'When the server responds with JSON', ->
    data = test: true
    json = JSON.stringify data
    content-type = 'application/json'
    response-fn = testServer.createGetResponse json, content-type

    cont 'And the request said to parse the response as JSON', ->
      expected-body = data
      {uri} = add-route-response '/testGetJSON', response-fn
      options = uri: uri, json: true

      o 'Return the parsed JSON', (done) ->
        tag options, deep-equal(expected-body, done)

    cont 'And the request did not say to parse the response as JSON', ->
      expected-body = json
      {uri} = add-route-response '/testGetJSONString', response-fn
      options = uri: uri, json: false

      o 'Return the JSON string', (done) ->
        tag options, equal(expected-body, done)

  # PUT/POST Requests

  cont 'When sending data to a server', ->

    cont 'And the request sends a string', ->
      body = 'test'
      expected-body = body
      response-fn = testServer.createPostValidator body, (data) ->
        expect(data).to.eq expected-body
      {uri} = add-route-response '/testPutString', response-fn
      options = uri: uri, method: 'PUT', body: body

      o 'Server receives the string', (done) ->
        tag options, (err, res, body) ->
          expect(err).to.eq null
          done err
