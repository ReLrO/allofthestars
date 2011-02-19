require 'rubygems'
require 'bundler'

module AllOfTheStars
  class << self
    attr_accessor :env, :riak_client
  end
  self.env = (ENV['STARS_ENV'] || :dev).to_sym
end

Bundler.require(:default, AllOfTheStars.env)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

AllOfTheStars.riak_client = Riak::Client.new(:http_backend => :Excon)
require 'allofthestars/cluster'
require 'allofthestars/star'

if defined?(Sinatra)
  require 'allofthestars/web'
else
  require 'irb'
  # http://jameskilton.com/2009/04/02/embedding-irb-into-your-ruby-application/
  module IRB # :nodoc:
    def self.start_session(binding)
      unless @__initialized
        args = ARGV
        ARGV.replace(ARGV.dup)
        IRB.setup(nil)
        ARGV.replace(args)
        @__initialized = true
      end

      ws  = WorkSpace.new(binding)
      irb = Irb.new(ws)

      @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
      @CONF[:MAIN_CONTEXT] = irb.context

      catch(:IRB_EXIT) do
        irb.eval_input
      end
    end
  end

  IRB.start_session(binding)
end
