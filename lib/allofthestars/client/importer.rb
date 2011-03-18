require 'allofthestars/client'
require 'time'
require 'pp'

module AllOfTheStars
  module Importers
    autoload :Twitter, 'allofthestars/client/importers/twitter'
  end

  module Importer
    include Importers::Twitter

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

    def config(key, value = nil)
      return nil if !@redis
      if value
        @redis.set key, value.to_s
      else
        @redis.get key
      end
    end

    def redis=(r)
      @redis = r
    end
  end
end
