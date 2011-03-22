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
    attr_accessor :riak_client, :redis_client, :stratocaster
  end

  options = {:http_backend => :Excon}
  config  = File.expand_path('../../../db/config.json', __FILE__)
  if File.exist?(config)
    data = ActiveSupport::JSON.decode(IO.read(config))
    data.each do |key, value|
      options[key.to_sym] = value
    end
  end

  self.riak_client  = Riak::Client.new(options)
  self.redis_client = Redis.new(:thread_safe => true)

  module Timelines
    class Type < Stratocaster::Timeline
      adapter Stratocaster::Adapters::Redis.new(AllOfTheStars.redis_client,
                                                :prefix => 'strat')

      key_format "%s:type:%s" do |msg|
        [msg.cluster_id, msg.type]
      end
    end

    class Cluster < Stratocaster::Timeline
      adapter Type.adapters.first

      key_format "%s" do |msg|
        msg.cluster_id
      end
    end

    class HashTag < Stratocaster::Timeline
      extend Twitter::Extractor
      adapter Type.adapters.first

      key_format "%s:hashtag:%s" do |msg, keys|
        extract_hashtags(msg.content).each do |hashtag|
          keys << [msg.cluster_id, hashtag]
        end
      end

      accept do |msg|
        msg.type == 'Twitter'
      end
    end

    class ScreenName < Stratocaster::Timeline
      extend Twitter::Extractor
      adapter Type.adapters.first

      key_format "%s:screenname:%s" do |msg, keys|
        extract_mentioned_screen_names(msg.content).each do |name|
          keys << [msg.cluster_id, name]
        end
      end

      accept do |msg|
        msg.type == 'Twitter'
      end
    end
  end

  self.stratocaster = Stratocaster.new \
    AllOfTheStars::Timelines::Type,
    AllOfTheStars::Timelines::HashTag,
    AllOfTheStars::Timelines::ScreenName
end

%w(searchable cluster star).each do |lib|
  require "allofthestars/server/#{lib}"
end
