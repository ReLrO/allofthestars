require 'toystore'
require 'adapter'
require 'adapter/riak'
require 'riak/search'

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
end

%w(searchable cluster star).each do |lib|
  require "allofthestars/server/#{lib}"
end
