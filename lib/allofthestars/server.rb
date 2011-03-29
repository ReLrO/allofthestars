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

  module Feeds
    class Type < Stratocaster::Feed
      adapter Stratocaster::Adapters::Redis.new(AllOfTheStars.redis_client,
                                                :prefix => 'strat')
      adapter Stratocaster::Adapters::Riak.new(AllOfTheStars.riak_client['stratocaster'])

      on_receive do |msg|
        {:cluster => msg.cluster_id, :type => msg.type}
      end
    end

    class Cluster < Stratocaster::Feed
      adapter Type.adapters[0]
      adapter Type.adapters[1]

      on_receive do |msg|
        {:cluster => msg.cluster_id}
      end
    end

    class HashTag < Stratocaster::Feed
      extend Twitter::Extractor
      adapter Type.adapters[0]
      adapter Type.adapters[1]

      on_receive do |msg, feeds|
        extract_hashtags(msg.content).each do |hashtag|
          feeds << {:cluster => msg.cluster_id, :hashtag => hashtag}
        end
      end

      accept do |msg|
        msg.type == 'Twitter'
      end
    end

    class ScreenName < Stratocaster::Feed
      extend Twitter::Extractor
      adapter Type.adapters[0]
      adapter Type.adapters[1]

      on_receive do |msg, feeds|
        extract_mentioned_screen_names(msg.content).each do |name|
          feeds << {:cluster => msg.cluster_id, :name => name}
        end
      end

      accept do |msg|
        msg.type == 'Twitter'
      end
    end
  end

  self.stratocaster = Stratocaster.new \
    AllOfTheStars::Feeds::Type,
    AllOfTheStars::Feeds::HashTag,
    AllOfTheStars::Feeds::ScreenName
end

%w(searchable cluster star).each do |lib|
  require "allofthestars/server/#{lib}"
end
