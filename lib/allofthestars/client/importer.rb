require 'allofthestars/client'
require 'pp'

module AllOfTheStars
  module Importer
    def import_tweet(id)
      require 'twitter'

      tweet = Twitter.status(id)
      data = {
        :type       => "Twitter",
        :content    => tweet.text,
        :source_url =>
          %(http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}),
        :custom     => {
          :user => tweet.user.screen_name,
          :retweet_count => tweet.retweet_count.to_i
        }
      }

      if in_reply_name = tweet.in_reply_to_screen_name
        data[:custom][:in_reply_to] =
          "http://twitter.com/#{in_reply_name}/status/#{tweet.in_reply_to_status_id_str}"
      end

      add_star(data, tweet)
    end

    def add_star(data, *debuggables)
      if debug?
        debuggables.each { |d| pp d }
        puts
        puts "DATA TO BE POSTED:"
        pp data
        return
      end

      resp = client.add_star(cluster_id, data)
      puts "Posted to #{client.inspect}:"
      pp data
      puts
      puts "Status: #{resp.status}"
      pp resp.headers
    end

    def debug?
      !!@debug
    end

    def debug!
      @debug = true
    end

    def client
      @client ||= Client.new
    end

    def cluster_id
      @cluster_id
    end

    def cluster_id=(val)
      @cluster_id = val
    end
  end
end
