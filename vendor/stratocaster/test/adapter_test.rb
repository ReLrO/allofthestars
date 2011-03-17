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
    @adapter = self.class.adapter_block.call(adapter_options)
    @adapter.clear "abc"
    @adapter.store "abc", 'id' => 1
    @adapter.store "abc", 'id' => 2
    @adapter.store "abc", 'id' => 3
  end

  def test_retrieves_latest_message_ids
    assert_equal %w(3 2), @adapter.page('abc', 1)
  end

  def test_retrieves_paginated_ids
    assert_equal %w(1), @adapter.page('abc', 2)
  end

  def test_counts_messages
    assert_equal 3, @adapter.count('abc')
    assert_equal 0, @adapter.count('def')
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
      assert_equal 3, no_max_adapter.count('abc')
      no_max_adapter.store 'abc', 'id' => 4
      assert_equal 4, no_max_adapter.count('abc')
    end
  end

rescue LoadError
  puts "No Redis tests"
end
