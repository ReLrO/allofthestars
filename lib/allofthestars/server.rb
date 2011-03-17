require 'bundler'

Bundler.setup(:default, :server)

require 'toystore'
require 'adapter'
require 'adapter/riak'
require 'redis'
require 'riak/search'
require 'stratocaster'

module AllOfTheStars
  class << self
    attr_accessor :riak_client
  end

  options = {:http_backend => :Excon}
  config  = File.expand_path('../../../db/config.json', __FILE__)
  if File.exist?(config)
    data = ActiveSupport::JSON.decode(IO.read(config))
    data.each do |key, value|
      options[key.to_sym] = value
    end
  end

  self.riak_client = Riak::Client.new(options)

  module Timelines
    class Type < Stratocaster::Timeline
      adapter Stratocaster::Adapters::Redis.new(Redis.new, :prefix => "strat")
      key_format "type:%s" do |msg|
        msg.type
      end
    end
  end
end

%w(searchable cluster star).each do |lib|
  require "allofthestars/server/#{lib}"
end
