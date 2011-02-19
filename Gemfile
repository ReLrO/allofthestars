source "http://rubygems.org"

gem 'yajl-ruby', :require => 'yajl'

group :client do
  gem 'faraday'
end

group :server do
  gem 'excon'
  gem "toystore"
  gem "adapter"
  gem "adapter-riak",  :require => 'adapter/riak'
  gem "adapter-redis", :require => 'adapter/redis'
  gem "redis"
  gem "riak-client", :require => 'riak/search'
  gem "sinatra", :require => false
end
