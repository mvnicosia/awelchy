require './server'
require 'rack/server'

Rack::Server.start :app => Awelchy
