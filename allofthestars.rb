require 'rubygems'
require 'bundler'

module AllOfTheStars
  class << self
    attr_accessor :env, :riak_client
  end
  self.env = (ENV['RACK_ENV'] || ENV['STARS_ENV'] || :dev).to_sym
end

Bundler.require(:default, AllOfTheStars.env)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

AllOfTheStars.riak_client = Riak::Client.new(:http_backend => :Excon)
require 'allofthestars/cluster'
require 'allofthestars/star'
