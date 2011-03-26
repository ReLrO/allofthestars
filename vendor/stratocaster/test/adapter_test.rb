require File.expand_path('../helper', __FILE__)

class AdapterTest < Test::Unit::TestCase
  class << self
    attr_reader :adapter_block

    def adapter
      @adapter_block = Proc.new
    end
  end

  adapter do |options|
    Stratocaster::Adapters::Memory.new({}, options)
  end

  def setup
    adapter_options = {:per_page => 2}
    @feed    = Stratocaster::Feed.new(:key => 'abc')
    @adapter = self.class.adapter_block.call(adapter_options)
    @adapter.clear @feed
    @adapter.store [@feed], 'id' => 1
    @adapter.store [@feed], 'id' => 2
    @adapter.store [@feed], 'id' => 3
  end

  def test_retrieves_latest_message_ids
    assert_equal %w(3 2), @adapter.page(@feed, 1)
  end

  def test_retrieves_paginated_ids
    assert_equal %w(1), @adapter.page(@feed, 2)
  end

  def test_counts_messages
    assert_equal 3, @adapter.count(@feed)
    assert_equal 0, @adapter.count(Stratocaster::Feed.new)
  end
end

require 'rubygems'

begin
  require 'redis'

  class RedisTest < AdapterTest
    adapter do |options|
      Stratocaster::Adapters::Redis.new Redis.new, options
    end

    def test_doesnt_truncate_list_with_zero_max
      no_max_adapter = @adapter.dup
      no_max_adapter.options[:max] = 0
      assert_equal 3, no_max_adapter.count(@feed)
      no_max_adapter.store [@feed], 'id' => 4
      assert_equal 4, no_max_adapter.count(@feed)
    end
  end

rescue LoadError
  puts "No Redis tests"
end
