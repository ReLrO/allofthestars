require 'rubygems'
require 'bundler'

module AllOfTheStars
  class << self
    attr_accessor :env, :riak_client
  end
end

Bundler.require(:default)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

options = {:http_backend => :Excon}
config  = File.expand_path('../db/config.json', __FILE__)
if File.exist?(config)
  data = ActiveSupport::JSON.decode(IO.read(config))
  data.each do |key, value|
    options[key.to_sym] = value
  end
end

AllOfTheStars.riak_client = Riak::Client.new(options)
require 'allofthestars/cluster'
require 'allofthestars/star'
