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

options = {:http_backend => :Excon}
if AllOfTheStars.env == :production
  options[:host] = 'riak1.allofthestars.com'
end
AllOfTheStars.riak_client = Riak::Client.new(options)
require 'allofthestars/cluster'
require 'allofthestars/star'
