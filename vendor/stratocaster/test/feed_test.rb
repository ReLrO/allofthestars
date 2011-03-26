require File.expand_path('../helper', __FILE__)

class FeedTest < Test::Unit::TestCase
  class CommentFeed < Stratocaster::Feed
    adapter Stratocaster::Adapters::Memory.new({})

    accept do |message|
      message['payload']['comment']
    end

    on_receive do |msg, feeds|
      feeds << {:comment => msg['payload']['comment'],
                :actor   => msg['actor']['id']}
    end
  end

  def setup
    @message = {'id' => 123, 'actor' => {'id' => 321}, 'payload' => {}}
    @comment = @message.merge('payload' => {'comment' => 5})
    @adapter = CommentFeed.adapters.first
    @feed    = CommentFeed.new :comment => 5, :actor => 321

    @adapter.client.clear

    CommentFeed.deliver(@comment)
  end

  def test_deliver_returns_key
    feeds = CommentFeed.deliver(@comment)
    feed  = feeds.shift
    assert_equal 0,   feeds.size
    assert_equal 5,   feed[:comment]
    assert_equal 321, feed[:actor]
  end

  def test_checks_if_feed_accepts_message
    assert !CommentFeed.accept?(@message)
  end

  def test_queries_adapter_for_message_ids
    assert_equal %w(123), @feed.page(1)
    assert_equal %w(123), @adapter.page(@feed, 1)
  end

  def test_counts_messages_in_adapter
    assert_equal 1, @feed.count
  end

  def test_uses_first_adapter_by_default
    assert_equal "Stratocaster::Adapters::Memory",
      @adapter.class.name
  end
end
