require 'rubygems'
require 'bundler'

Bundler.setup(:default, :server)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'allofthestars/server/web'

run AllOfTheStars::Web
