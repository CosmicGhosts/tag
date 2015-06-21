require! {
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

server = createServer!
valid-url = "#{server.url}/valid"
invalid-url = "#{server.url}/invalid"

default-response-fn = (req, res) ->
  if req.url is '/valid'
    res.setHeader('set-cookie', 'foo=bar')
  else if req.url is '/invalid'
    res.setHeader('set-cookie', 'foo=bar; Domain=foo.com')
  res.end 'okay'

desc 'Feature: Cookies', ->
  before (done) -> server.listen port, -> done!
  after  (done) -> server.close -> done!

  cont 'When given a key and value', ->
    o 'Creates a Simple Cookie', ->
      cookie = tag.cookie 'foo=bar'
      expect(cookie.key).to.eq 'foo'
      expect(cookie.value).to.eq 'bar'

  cont 'When a server sends a cookie', ->
    jar = tag.jar!
    options =
      method: 'GET'
      uri: valid-url
      jar: jar

    o 'Creates cookie in jar', (done) ->
      tag options, (err, res, body) ->
        expect(err).to.eq null
        expect(jar.getCookieString valid-url).to.eq 'foo=bar'
        expect(body).to.eq 'okay'

        cookies = jar.getCookies valid-url
        expect(cookies.length).to.eq 1
        expect(cookies[0].key).to.eq 'foo'
        expect(cookies[0].value).to.eq 'bar'

        done err
