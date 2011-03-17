require 'bundler'

Bundler.setup(:default, :server)

require 'toystore'
require 'adapter'
require 'adapter/riak'
require 'redis'
require 'riak/search'
require 'stratocaster'
require File.expand_path('../../../vendor/twitter-text-rb/lib/regex', __FILE__)
require File.expand_path('../../../vendor/twitter-text-rb/lib/extractor', __FILE__)

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

  def self.stratocaster
    Stratocaster.new AllOfTheStars::Timelines::Type,
      AllOfTheStars::Timelines::HashTag,
      AllOfTheStars::Timelines::ScreenName
  end

  module Timelines
    class Type < Stratocaster::Timeline
      adapter Stratocaster::Adapters::Redis.new(Redis.new, :prefix => "strat")
      key_format "type:%s" do |msg|
        msg.type
      end
    end

    class HashTag < Stratocaster::Timeline
      extend Twitter::Extractor

      adapter Type.adapters.first
      key_format "hashtag:%s" do |msg, keys|
        keys.push *extract_hashtags(msg.content)
      end

      accept do |msg|
        msg.type == 'Twitter'
      end
    end

    class ScreenName < Stratocaster::Timeline
      extend Twitter::Extractor

      adapter Type.adapters.first
      key_format "screenname:%s" do |msg, keys|
        keys.push *extract_mentioned_screen_names(msg.content)
      end

      accept do |msg|
        msg.type == 'Twitter'
      end
    end
  end
end

%w(searchable cluster star).each do |lib|
  require "allofthestars/server/#{lib}"
end
