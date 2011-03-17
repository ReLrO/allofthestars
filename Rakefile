require 'rubygems'
require 'rake'

namespace :server do
  desc "Start the server in a rack process"
  task :start do
    sh "rackup config.ru"
  end

  desc "Start an irb session with the server models loaded"
  task :console do
    sh "irb -I lib -r allofthestars/server"
  end
end

desc "Start an irb session with the HTTP client loaded"
task :console do
  sh "irb -I lib -r allofthestars/client"
end

namespace :import do
  desc "Import a single Tweet.  Needs CLUSTER_ID= and TWEET={status-id}"
  task :tweet => :init do
    import_tweet ENV['TWEET'].to_i
  end

  task :instagram => :init do
    #import_instagram
  end

  # STARS_URL - String URL to AllOfTheStars instance.  Defaults to
  #             http://allofthestars.com
  # CLUSTER_ID - String Cluster ID
  # DEBUG      - Add this to see what's about to be posted without
  #              actually importing the star.
  task :init do
    require 'bundler'
    Bundler.setup :default, :client, :importers
    $:.unshift File.expand_path("../lib", __FILE__)
    require 'allofthestars/client/importer'

    if url = ENV['STARS_URL']
      AllOfTheStars::Client.default_url = url
    end

    extend AllOfTheStars::Importer
    self.cluster_id = ENV['CLUSTER_ID']
    debug! if ENV['DEBUG']
  end
end
