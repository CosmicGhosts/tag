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

server = createServer!

desc 'Feature: Request Agent Options', ->
  before (done) -> server.listen port, -> done!
  after  (done) -> server.close -> done!

  cont 'When using the Agent Options', ->
    expected-body = 'test'
    route = '/testAgentOptions'
    uri = make-full-route server, route
    response-fn = create-get-response expected-body
    add-route-response server, route, response-fn
    agent-options = foo: 'bar'
    options =
      uri: uri
      agentOptions: agent-options

    o 'Use the Custom AgentOptions', (done) ->
      op = 'eq'
      r = tag options, (err, res, body) ->
        # TODO: figure out why err.code === 'ECONNREFUSED' on Travis?
        if (err) then console.log(err)
        expect(err).to[op] null
        expect(r.agent.options.foo).to.eq agent-options.foo
        expect(r.agent).to.not.eq http.globalAgent
        done err

    # TODO: Figure out how to test that the pool was added to
    x 'Adds the Custom Agent to the manual pool', (done) ->
      op = 'eq'
      r = tag options, (err, res, body) ->
        # TODO: figure out why err.code === 'ECONNREFUSED' on Travis?
        if (err) then console.log(err)
        expect(err).to[op] null
        console.log r.pool
        expect(Object.keys(r.pool).length).to[op] 1
        done err

  cont 'When not using the Agent Options', (done) ->
    expected-body = 'test'
    route = '/testWithoutAgentOptions'
    uri = make-full-route server, route
    response-fn = create-get-response expected-body
    add-route-response server, route, response-fn
    options = uri: uri

    o 'Use the Global Agent', (done) ->
      op = 'eq'
      r = tag options, (err, res, body) ->
        # TODO: figure out why err.code === 'ECONNREFUSED' on Travis?
        if (err) then console.log(err)
        expect(err).to[op] null
        expect(r.agent).to[op] http.globalAgent
        done err

    # TODO: Figure out how to test that the pool was added to
    x 'Does not add to manual request pool', (done) ->
      op = 'eq'
      r = tag options, (err, res, body) ->
        # TODO: figure out why err.code === 'ECONNREFUSED' on Travis?
        if (err) then console.log(err)
        expect(err).to[op] null
        console.log r.pool
        expect(Object.keys(r.pool).length).to[op] 0
        done err
