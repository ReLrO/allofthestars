require File.expand_path('../helper', __FILE__)

class TimelineTest < Test::Unit::TestCase
  class CommentTimeline < Stratocaster::Timeline
    self.adapters << Stratocaster::Adapters::Memory.new({})

    def self.accept?(message)
      !!message['payload']['comment']
    end

    def self.key_for(message)
      "comment:#{message['payload']['comment']}"
    end

    def initialize(comment_id, options = {})
      super({'payload' => {'comment' => comment_id}}, options)
    end
  end

  def setup
    @message = {'id' => 123, 'actor' => {'id' => 321}, 'payload' => {}}
    @comment = @message.merge('payload' => {'comment' => 5})

    CommentTimeline.adapters.first.client.clear

    CommentTimeline.deliver(@comment)
  end

  def test_deliver_returns_key
    assert_equal 'actor:321', Stratocaster::Timeline.deliver(@message)
    assert_equal 'comment:5', CommentTimeline.deliver(@comment)
  end

  def test_checks_if_timeline_accepts_message
    assert !CommentTimeline.accept?(@message)
    assert  Stratocaster::Timeline.accept?(@message)
  end

  def test_queries_adapter_for_message_ids
    assert_equal %w(123), CommentTimeline.new(5).page(1)
    assert_equal %w(123), CommentTimeline.adapters.first.page('comment:5', 1)
  end

  def test_counts_messages_in_adapter
    assert_equal 1, CommentTimeline.new(5).count
  end

  def test_uses_first_adapter_by_default
    assert_equal "Stratocaster::Adapters::Memory",
      CommentTimeline.new(5).default_adapter.class.name
  end
end
