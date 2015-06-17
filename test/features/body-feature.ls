require! {
  './feature-spec-helper': {
    tag, o, x, desc, cont,
    expect, sinon, testServer
  }
}

add-route-response = testServer.addRouteResponse

server = testServer.createServer!

make-full-route = (route, server) ->
  "#{server.url}#{route}"

desc 'Feature: Request Body', ->
  before (done) -> server.listen testServer.port, -> done!
  after  (done) -> server.close -> done!

  # Get Requests

  cont 'When the server responds with a string', ->
    route = '/testGet'
    uri = make-full-route route, server
    expected-body = 'test'
    response-fn = testServer.createGetResponse expected-body
    add-route-response server, route, response-fn
    options = uri: uri

    o 'Return the string', (done) ->
      op = 'eq'
      tag options, (err, res, body) ->
        expect(err).to[op] null
        expect(res.body).to[op] expected-body
        expect(body).to[op] expected-body
        done err

  cont 'When the server responds with a buffer', ->
    cont 'And the request asked for default encoding', ->
      route = '/testGetBufferDefault'
      uri = make-full-route route, server
      expected-body = 'test'
      response-fn = testServer.createGetResponse new Buffer expected-body
      add-route-response server, route, response-fn
      options = uri: uri

      o 'Return the default encoded buffer', (done) ->
        op = 'eq'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(body).to[op] expected-body
          done err

    cont 'And the request asked for no encoding', ->
      route = '/testGetBufferNoEncoding'
      uri = make-full-route route, server
      expected-body = new Buffer 'test'
      response-fn = testServer.createGetResponse expected-body
      add-route-response server, route, response-fn
      options = uri: uri, encoding: null

      o 'Return the buffer', (done) ->
        op = 'eql'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(body).to[op] expected-body
          done err

    cont 'And the request asked for HEX encoding', ->
      route = '/testGetBufferHex'
      uri = make-full-route route, server
      expected-body = '74657374'
      response-fn = testServer.createGetResponse new Buffer expected-body, 'hex'
      add-route-response server, route, response-fn
      options = uri: uri, encoding: 'hex'

      o 'Return the HEX encoded buffer', (done) ->
        op = 'eq'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(body).to[op] expected-body
          done err

    cont 'And the request asked for UTF8 encoding', ->
      route = '/testGetBufferUTF8'
      uri = make-full-route route, server
      expected-body = 'test'
      response-fn = testServer.createGetResponse new Buffer [116, 101, 115, 116]
      add-route-response server, route, response-fn
      options = uri: uri, encoding: 'utf8'

      o 'Return the UTF8 encoded buffer', (done) ->
        op = 'eq'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(body).to[op] expected-body
          done err

  cont 'When the server responds with chunked data', ->
    route = '/testGetChunk'
    uri = make-full-route route, server
    chunks = ['t', 'e', 's', 't']
    expected-body = chunks.join ''
    response-fn = testServer.createChunkResponse expected-body
    add-route-response server, route, response-fn
    options = uri: uri

    o 'Return the complete data', (done) ->
      op = 'eq'
      tag options, (err, res, body) ->
        expect(err).to[op] null
        expect(res.body).to[op] expected-body
        expect(body).to[op] expected-body
        done err

  cont 'When the server responds with JSON', ->
    data = test: true
    json = JSON.stringify data
    content-type = 'application/json'
    response-fn = testServer.createGetResponse json, content-type

    cont 'And the request said to parse the response as JSON', ->
      route = '/testGetJSON'
      uri = make-full-route route, server
      expected-body = data
      add-route-response server, route, response-fn
      options = uri: uri, json: true

      o 'Return the parsed JSON', (done) ->
        op = 'eql'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(body).to[op] expected-body
          done err

    cont 'And the request did not say to parse the response as JSON', ->
      route = '/testGetJSONString'
      uri = make-full-route route, server
      expected-body = json
      add-route-response server, route, response-fn
      options = uri: uri, json: false

      o 'Return the JSON string', (done) ->
        op = 'eq'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(body).to[op] expected-body
          done err

  # PUT/POST Requests

  cont 'When sending data to a server', ->
    cont 'And the request sends a string', ->
      route = '/testPutString'
      uri = make-full-route route, server
      body = 'test'
      expected-body = body
      response-fn = testServer.createPostValidator (data) ->
        expect(data).to.eq expected-body
      add-route-response server, route, response-fn
      options = uri: uri, method: 'PUT', body: body

      o 'Server receives the string', (done) ->
        tag options, (err, res, body) ->
          expect(err).to.eq null
          done err

    cont 'And the request sends a buffer', ->
      route = '/testPutBuffer'
      uri = make-full-route route, server
      body = new Buffer 'test'
      expected-body = body.toString!
      response-fn = testServer.createPostValidator (data) ->
        expect(data).to.eq expected-body
      add-route-response server, route, response-fn
      options = uri: uri, method: 'PUT', body: body

      o 'Server receives the buffer converted to string', (done) ->
        tag options, (err, res, body) ->
          expect(err).to.eq null
          done err

    cont 'And the request sends JSON', ->
      route = '/testPutJSON'
      uri = make-full-route route, server
      obj = foo: 'bar'
      body = JSON.stringify obj
      expected-body = body
      response-fn = testServer.createPostValidator (data) ->
        expect(data).to.eq expected-body
      add-route-response server, route, response-fn
      options = uri: uri, method: 'PUT', json: obj

      o 'Server receives the JSON string', (done) ->
        tag options, (err, res, body) ->
          expect(err).to.eq null
          done err

    cont 'And the request sends Multipart data', ->
      cont 'And the body has the default CLRF', ->
        route = '/testPutMultipart'
        uri = make-full-route route, server
        expected-body =
          '--__BOUNDARY__\r\n' +
          'content-type: text/html\r\n' +
          '\r\n' +
          '<html><body>test</body></html>' +
          '\r\n--__BOUNDARY__\r\n\r\n' +
          'test' +
          '\r\n--__BOUNDARY__--'

        response-fn = testServer.createPostValidator (data, req) ->
          expect(data).to.eq testServer.patchBoundaries expected-body, req

        add-route-response server, route, response-fn

        options =
          uri: uri
          method: 'PUT'
          multipart: [
            {'content-type': 'text/html', 'body': '<html><body>test</body></html>'}
            {'body': 'test'}
          ]

        o 'Server receives the Multipart data', (done) ->
          tag options, (err, res, body) ->
            expect(err).to.eq null
            done err

      cont 'And the body has Preamble CRLF', ->
        route = '/testPutMultipartPreambleCRLF'
        uri = make-full-route route, server
        expected-body =
          '\r\n--__BOUNDARY__\r\n' +
          'content-type: text/html\r\n' +
          '\r\n' +
          '<html><body>test</body></html>' +
          '\r\n--__BOUNDARY__\r\n\r\n' +
          'test' +
          '\r\n--__BOUNDARY__--'

        response-fn = testServer.createPostValidator (data, req) ->
          expect(data).to.eq testServer.patchBoundaries expected-body, req
        add-route-response server, route, response-fn
        options =
          uri: uri
          method: 'PUT'
          preambleCRLF: true
          multipart: [
            {'content-type': 'text/html', 'body': '<html><body>test</body></html>'}
            {'body': 'test'}
          ]

        o 'Server receives the Multipart data', (done) ->
          tag options, (err, res, body) ->
            expect(err).to.eq null
            done err

      cont 'And the body has Postamble CRLF', ->
        route = '/testPutMultipartPostambleCRLF'
        uri = make-full-route route, server
        expected-body =
          '--__BOUNDARY__\r\n' +
          'content-type: text/html\r\n' +
          '\r\n' +
          '<html><body>test</body></html>' +
          '\r\n--__BOUNDARY__\r\n\r\n' +
          'test' +
          '\r\n--__BOUNDARY__--' +
          '\r\n'

        response-fn = testServer.createPostValidator (data, req) ->
          expect(data).to.eq testServer.patchBoundaries expected-body, req
        add-route-response server, route, response-fn
        options =
          uri: uri
          method: 'PUT'
          postambleCRLF: true
          multipart: [
            {'content-type': 'text/html', 'body': '<html><body>test</body></html>'}
            {'body': 'test'}
          ]

        o 'Server receives the Multipart data', (done) ->
          tag options, (err, res, body) ->
            expect(err).to.eq null
            done err

      cont 'And the body has bost Preamble and Postamble CRLF', ->
        route = '/testPutMultipartPreamblePostambleCRLF'
        uri = make-full-route route, server
        expected-body =
          '\r\n--__BOUNDARY__\r\n' +
          'content-type: text/html\r\n' +
          '\r\n' +
          '<html><body>test</body></html>' +
          '\r\n--__BOUNDARY__\r\n\r\n' +
          'test' +
          '\r\n--__BOUNDARY__--' +
          '\r\n'

        response-fn = testServer.createPostValidator (data, req) ->
          expect(data).to.eq testServer.patchBoundaries expected-body, req
        add-route-response server, route, response-fn
        options =
          uri: uri
          method: 'PUT'
          preambleCRLF: true
          postambleCRLF: true
          multipart: [
            {'content-type': 'text/html', 'body': '<html><body>test</body></html>'}
            {'body': 'test'}
          ]

        o 'Server receives the Multipart data', (done) ->
          tag options, (err, res, body) ->
            expect(err).to.eq null
            done err
