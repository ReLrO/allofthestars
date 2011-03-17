require File.expand_path('../helper', __FILE__)

class TimelineTest < Test::Unit::TestCase
  class CommentTimeline < Stratocaster::Timeline
    adapter Stratocaster::Adapters::Memory.new({})

    key_format "comment:%d:%d" do |message|
      # turns nils to zero
      [message['payload']['comment'].to_i,
        message['actor']['id']]
    end

    # specifically override the key format block
    accept do |message|
      message['payload']['comment']
    end
  end

  def setup
    @message = {'id' => 123, 'actor' => {'id' => 321}, 'payload' => {}}
    @comment = @message.merge('payload' => {'comment' => 5})

    CommentTimeline.adapters.first.client.clear

    CommentTimeline.deliver(@comment)
  end

  def test_deliver_returns_key
    assert_equal 'comment:5:321', CommentTimeline.deliver(@comment)
  end

  def test_checks_if_timeline_accepts_message
    assert !CommentTimeline.accept?(@message)
  end

  def test_queries_adapter_for_message_ids
    assert_equal %w(123), CommentTimeline.new(5, 321).page(1)
    assert_equal %w(123), CommentTimeline.adapters.first.page('comment:5:321', 1)
  end

  def test_counts_messages_in_adapter
    assert_equal 1, CommentTimeline.new(5, 321).count
  end

  def test_uses_first_adapter_by_default
    assert_equal "Stratocaster::Adapters::Memory",
      CommentTimeline.new(5, 321).default_adapter.class.name
  end
end
