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

    def test_truncates_list_with_zero_max
      max_adapter = @adapter.dup
      max_adapter.options[:max] = 2
      assert_equal 3, max_adapter.count(@feed)
      max_adapter.store [@feed], 'id' => 4
      assert_equal 2, max_adapter.count(@feed)
      assert_equal '4', max_adapter.page(@feed, 1).first
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

begin
  require 'riak/client'

  class RiakTest < AdapterTest
    BUCKET = Riak::Client.new["strat-#{Time.now.to_i}"]
    BUCKET.allow_mult = true

    adapter do |options|
      Stratocaster::Adapters::Riak.new BUCKET, options
    end

    def test_retrieves_latest_message_ids
      items = @adapter.page(@feed, 1)
      assert_equal({'id' => 3}, items.shift)
      assert_equal({'id' => 2}, items.shift)
      assert_nil items.shift
    end

    def test_retrieves_paginated_ids
      assert_equal [{'id' => 1}], @adapter.page(@feed, 2)
    end

    def test_truncates_list_with_zero_max
      max_adapter = @adapter.dup
      max_adapter.options[:max] = 2
      assert_equal 3, max_adapter.count(@feed)
      max_adapter.store [@feed], 'id' => 4
      assert_equal 2, max_adapter.count(@feed)
      assert_equal({'id' => 4}, max_adapter.page(@feed, 1).first)
    end

    def test_doesnt_truncate_list_with_zero_max
      no_max_adapter = @adapter.dup
      no_max_adapter.options[:max] = 0
      assert_equal 3, no_max_adapter.count(@feed)
      no_max_adapter.store [@feed], 'id' => 4
      assert_equal 4, no_max_adapter.count(@feed)
    end

    def test_handles_conflict
      obj = BUCKET.new 'feed:conflicted'
      obj.data = [[1, {"id" => 2}]]
      obj.store
      obj.vclock = nil # create a conflict
      obj.data = [[0, {"id" => 1}], [3, {'id' => 3}]]
      obj.store

      # its conflicted in riak
      obj = BUCKET.get obj.key
      assert obj.conflict?

      # fetch a feed, which should fix the conflict
      feed  = Stratocaster::Feed.new(:key => 'conflicted')
      assert_equal 3, @adapter.count(feed)
      items = @adapter.page(feed, 1)
      assert_equal 3, items.shift['id']
      assert_equal 2, items.shift['id']

      # assert that its fixed, and the keys are ordered by time
      obj = BUCKET.get obj.key
      assert !obj.conflict?
      assert_equal 3, obj.data.shift.last['id']
      assert_equal 2, obj.data.shift.last['id']
      assert_equal 1, obj.data.shift.last['id']
      assert obj.data.empty?
    end
  end

rescue LoadError
  puts "No Riak tests"
end
