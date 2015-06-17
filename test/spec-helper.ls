tag = require '../src'

chai = require 'chai'
sinon = require 'sinon'
sinon-chai = require 'sinon-chai'

chai.use sinon-chai

module.exports =
  o: it
  x: it.skip
  desc: describe
  cont: context
  sinon: sinon
  expect: chai.expect
  tag: tag
