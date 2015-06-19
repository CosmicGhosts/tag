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

destroy-agent = (agent) ->
  if typeof agent.destroy is 'function'
    return agent.destroy!

  Object.keys(agent.sockets)
    .map (name) -> agent.sockets[name]
    .reduce (xs, ys) -> xs.concat ys
    .forEach (socket) -> socket.destroy!

reset-sockets = (agent) ->
  agent.sockets = {}

clean-up-agent = (agent) ->
  destroy-agent agent
  reset-sockets agent

desc 'Feature: Request Agent', ->
  before (done) -> server.listen port, -> done!
  after  (done) -> server.close -> done!

  cont 'When using default Agent', ->
    cont 'And using only 1 socket', ->
      expected-body = 'test'
      route = '/testAgent'
      uri = make-full-route server, route
      response-fn = create-get-response expected-body
      add-route-response server, route, response-fn
      options =
        uri: uri
        headers: 'Connection':'Close'
        pool: maxSockets: 1

      o 'Make the request', (done) ->
        op = 'eq'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.request.agent.maxSockets).to[op] 1
          done err

  cont 'When using ForeverAgent', ->
    cont 'And when using the `forever` function', ->
      expected-body = 'test'
      route = '/testForeverAgentFn'
      uri = make-full-route server, route
      response-fn = create-get-response expected-body
      add-route-response server, route, response-fn
      options = uri: uri, headers: 'Connection':'Close'

      o 'Make the request', (done) ->
        op = 'eq'
        tagFn = tag.forever maxSockets: 1
        tagFn options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(res.request.agent.maxSockets).to[op] 1
          expect(body).to[op] expected-body
          clean-up-agent res.request.agent
          done err

    cont 'And when using forever boolean flag', ->
      expected-body = 'test'
      route = '/testForeverAgentFlag'
      uri = make-full-route server, route
      response-fn = create-get-response expected-body
      add-route-response server, route, response-fn
      options =
        uri: uri
        headers: 'Connection':'Close'
        forever: true

      o 'Make the request', (done) ->
        op = 'eq'
        tag options, (err, res, body) ->
          expect(err).to[op] null
          expect(res.body).to[op] expected-body
          expect(body).to[op] expected-body
          clean-up-agent res.request.agent
          done err

    cont 'And when making multiple requests', ->
      expected-body = 'test'
      route = '/testForeverAgentMultiple'
      uri = make-full-route server, route
      response-fn = create-get-response expected-body
      add-route-response server, route, response-fn
      options =
        uri: uri
        headers: 'Connection':'keep-alive'
        method: 'POST',
        body: expected-body,
        forever: true

      # TODO: This test should really be in Forever Agent
      # Fails in Node 0.10
      x 'Persists one socket for all requests', (done) ->
        op = 'eq'
        tagFn = tag.forever!
        tagFn options, (err, res, body) ->
          expect(err).to[op] null

          if err
            clean-up-agent res.request.agent
            done err
            return

          tag options, (err, res2, body2) ->
            expect(err).to[op] null
            expect(res.socket).to[op] res2.socket
            clean-up-agent res.request.agent
            clean-up-agent res2.request.agent
            done err

      x 'Uses one Forever Agent for all requests', ->
