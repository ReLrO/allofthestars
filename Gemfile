source "http://rubygems.org"

gem 'excon'
gem 'yajl-ruby'
gem "redis"

group :client do
  gem 'faraday'
end

group :server do
  gem "toystore"
  gem "adapter"
  gem "adapter-riak"
  gem "adapter-redis"
  gem "riak-client"
  gem "sinatra"
  gem "stratocaster", :path => "vendor/stratocaster"
end

group :importers do
  gem "twitter"
  gem "instagram"
end
