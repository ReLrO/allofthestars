require File.expand_path('../helper', __FILE__)

class FeedTest < Test::Unit::TestCase
  class CommentFeed < Stratocaster::Feed
    adapter Stratocaster::Adapters::Memory.new({})

    accept do |message|
      message['payload']['comment']
    end

    key_format "comment:%d:%d" do |message, keys|
      keys << [message['payload']['comment'], message['actor']['id']]
    end
  end

  def setup
    @message = {'id' => 123, 'actor' => {'id' => 321}, 'payload' => {}}
    @comment = @message.merge('payload' => {'comment' => 5})

    CommentFeed.adapters.first.client.clear

    CommentFeed.deliver(@comment)
  end

  def test_deliver_returns_key
    assert_equal %w(comment:5:321), CommentFeed.deliver(@comment)
  end

  def test_checks_if_feed_accepts_message
    assert !CommentFeed.accept?(@message)
  end

  def test_queries_adapter_for_message_ids
    assert_equal %w(123), CommentFeed.new(5, 321).page(1)
    assert_equal %w(123), CommentFeed.adapters.first.page('comment:5:321', 1)
  end

  def test_counts_messages_in_adapter
    assert_equal 1, CommentFeed.new(5, 321).count
  end

  def test_uses_first_adapter_by_default
    assert_equal "Stratocaster::Adapters::Memory",
      CommentFeed.new(5, 321).default_adapter.class.name
  end
end
