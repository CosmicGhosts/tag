require! {
  http
  './feature-spec-helper': {
    tag,
    o, x, desc, cont,
    expect, sinon,
    testServer: {
      port
      create-server
      make-full-route
      create-get-response
      add-route-response
    }
  }
}

server = create-server!
default-base-url = make-full-route server, ''
getUriFrom = (req) -> req.uri.href
clean-up-server = (server, route) -> server.removeAllListeners route
format-uri = (uri) -> if uri is '' then "`empty string`" else uri
wo-protocol = (uri) -> uri.split('://')[1]

default-response-fn = (req, res) ->
  if req.url == '/redirects/'
    res.writeHead 302, location: '/'
  else
    res.statusCode = 200
    res.setHeader 'X-PATH', req.url
  res.end 'ok'

pass = (options, expected-path) ->
  {baseUrl, uri} = options
  clean-up-server server, expected-path
  add-route-response server, expected-path, default-response-fn
  cont "When given the Base URL: #{baseUrl} and the URI: #{format-uri uri}", ->
    o 'Fulfills the request', (done) ->
      tag options, (err, res, body) ->
        reqUri = getUriFrom res.request
        expect(err).to.eq null
        expect(body).to.eq 'ok'
        expect(res.headers['x-path']).to.eq expected-path
        done err

fail = (options, error-message) ->
  {baseUrl, uri} = options
  cont "When given the Base URL: #{baseUrl} and the URI: #{format-uri uri}", ->
    o 'Fails the request', (done) ->
      tag options, (err, res, body) ->
        expect(err).to.not.eq null
        expect(err.message).to.eq error-message
        done!

test-fns = {pass, fail}

add-test-case = (type, base, uri, expected-value) -->
  options = baseUrl: base, uri: uri
  fn = test-fns[type]
  fn options, expected-value

add-pass = add-test-case 'pass'
add-fail = add-test-case 'fail'

desc 'Feature: Base Url', ->
  before (done) -> server.listen port, -> done!
  after  (done) -> server.close -> done!

  cont 'With a Base Url', ->
    route = '/testBaseUrl'
    uri = "#{default-base-url}#{route}"
    add-route-response server, route, default-response-fn
    options = baseUrl: default-base-url

    o 'Fulfills the request', (done) ->
      tag route, options, (err, res, body) ->
        reqUri = getUriFrom res.request
        expect(err).to.eq null
        expect(body).to.eq 'ok'
        expect(reqUri).to.eq uri
        clean-up-server server, route
        done err

    cont 'and with Defaults', ->
      route = '/testBaseUrlWithDefaults'
      uri = "#{default-base-url}#{route}"
      add-route-response server, route, default-response-fn
      options = baseUrl: default-base-url

      o 'Fulfills the request', (done) ->
        tag-fn = tag.defaults options
        tag-fn route, (err, res, body) ->
          reqUri = getUriFrom res.request
          expect(err).to.eq null
          expect(body).to.eq 'ok'
          expect(reqUri).to.eq uri
          clean-up-server server, route
          done err

    cont 'and with Redirects' ->
      route = '/'
      redirect-partial-route = '/redirects'
      redirect-route = "#{redirect-partial-route}#{route}"
      uri = "#{default-base-url}#{route}"
      add-route-response server, route, default-response-fn
      add-route-response server, redirect-route, default-response-fn
      options = baseUrl: "#{default-base-url}#{redirect-partial-route}"

      o 'Fulfills the request', (done) ->
        tag route, options, (err, res, body) ->
          reqUri = getUriFrom res.request
          expect(err).to.eq null
          expect(body).to.eq 'ok'
          expect(reqUri).to.eq uri
          expect(res.headers['x-path']).to.eq route
          done err

    add-pass server.url, '', '/'
    add-pass server.url, '/', '/'
    add-pass "#{server.url}/", '', '/'
    add-pass "#{server.url}/", '/', '/'
    add-pass "#{server.url}/api", '', '/api'
    add-pass "#{server.url}/api", '/', '/api/'
    add-pass "#{server.url}/api/", '', '/api/'
    add-pass "#{server.url}/api/", '/', '/api/'
    add-pass "#{server.url}/api", 'resource', '/api/resource'
    add-pass "#{server.url}/api", '/resource', '/api/resource'
    add-pass "#{server.url}/api/", 'resource', '/api/resource'
    add-pass "#{server.url}/api/", '/resource', '/api/resource'
    add-pass "#{server.url}/api", 'resource/', '/api/resource/'
    add-pass "#{server.url}/api/", 'resource/', '/api/resource/'
    add-pass "#{server.url}/api", '/resource/', '/api/resource/'
    add-pass "#{server.url}/api/", '/resource/', '/api/resource/'

    add-fail {}, '', 'options.baseUrl must be a string'
    add-fail server.url, {}, 'options.uri must be a string when using options.baseUrl'
    add-fail "#{server.url}/path/", "#{server.url}/path/ignoring/baseUrl", 'options.uri must be a path when using options.baseUrl'
    add-fail "#{server.url}/path/", "//#{wo-protocol server.url}/path/ignoring/baseUrl", 'options.uri must be a path when using options.baseUrl'
