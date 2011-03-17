require File.expand_path("../helper", __FILE__)

class StratocasterTest < Test::Unit::TestCase
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
    @strat   = Stratocaster.new CommentTimeline, Stratocaster::Timeline
    @message = {'id' => 123, 'actor' => {'id' => 321}, 'payload' => {}}
    @comment = {'id' => 124, 'actor' => {'id' => 320}, 'payload' => {'comment' => 5}}
  end

  def test_tracks_timeline_classes
    assert_equal [CommentTimeline, Stratocaster::Timeline], @strat.timelines
  end

  def test_returns_list_of_delivered_timeline_keys
    assert_equal %w(actor:321), @strat.receive(@message)
    assert_equal %w(comment:5 actor:320), @strat.receive(@comment)
  end
end
