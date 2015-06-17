extend = require('util')._extend

spec-helper = require '../spec-helper'
feature-spec-helper = extend {}, spec-helper
feature-spec-helper.testServer = require './helpers/testServer'

module.exports = feature-spec-helper
