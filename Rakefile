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
