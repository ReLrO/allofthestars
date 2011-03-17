require File.expand_path("../helper", __FILE__)

class StratocasterTest < Test::Unit::TestCase
  class CommentTimeline < Stratocaster::Timeline
    adapters << Stratocaster::Adapters::Memory.new({})

    key_format "comment:%s" do |msg|
      msg['payload']['comment']
    end
  end

  def setup
    @strat   = Stratocaster.new CommentTimeline
    @message = {'id' => 123, 'actor' => {'id' => 321}, 'payload' => {}}
    @comment = {'id' => 124, 'actor' => {'id' => 320}, 'payload' => {'comment' => 5}}
  end

  def test_tracks_timeline_classes
    assert_equal [CommentTimeline], @strat.timelines
  end

  def test_returns_list_of_delivered_timeline_keys
    assert_equal [], @strat.receive(@message)
    assert_equal %w(comment:5), @strat.receive(@comment)
  end
end
