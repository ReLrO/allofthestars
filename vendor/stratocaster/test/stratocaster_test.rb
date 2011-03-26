require File.expand_path("../helper", __FILE__)

class StratocasterTest < Test::Unit::TestCase
  class CommentFeed < Stratocaster::Feed
    adapters << Stratocaster::Adapters::Memory.new({})

    on_receive do |msg|
      if comment = msg['payload']['comment']
        {:comment => comment}
      end
    end
  end

  def setup
    @strat   = Stratocaster.new CommentFeed
    @message = {'id' => 123, 'actor' => {'id' => 321}, 'payload' => {}}
    @comment = {'id' => 124, 'actor' => {'id' => 320}, 'payload' => {'comment' => 5}}
  end

  def test_tracks_feed_classes
    assert_equal [CommentFeed], @strat.feeds
  end

  def test_returns_list_of_delivered_feed_keys
    assert_equal [], @strat.receive(@message)
    feeds = @strat.receive(@comment)
    feed  = feeds.shift
    assert_equal 0, feeds.size
    assert_equal 5, feed[:comment]
  end
end
