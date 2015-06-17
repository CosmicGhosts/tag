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

desc 'Feature: Feature Name', ->
  before (done) -> server.listen port, -> done!
  after  (done) -> server.close -> done!
