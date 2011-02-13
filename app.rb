require 'rubygems'
require 'bundler'

module Gravastar
  class << self
    attr_accessor :env
  end
  self.env = (ENV['GRAVASTAR_ENV'] || :dev).to_sym
end

Bundler.require(:default, Gravastar.env)
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'gravastar/cluster'
require 'gravastar/star'

if defined?(Sinatra)
  require 'gravastar/web'
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
