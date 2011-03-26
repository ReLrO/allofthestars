class Stratocaster::Adapters::Redis < Stratocaster::Adapter
  def store(feeds, message)
    id = message['id'].to_s
    @client.pipelined do
      feeds.each do |feed|
        redis_key = key_for(feed)
        @client.lpush(redis_key, id)
        if (max = @options[:max]) > 0
          @client.ltrim(redis_key, 0, max-1)
        end
      end
    end
  end

  def page(feed, num)
    off = offset_for(num)
    @client.lrange(key_for(feed), off, off + @options[:per_page] - 1) || []
  end

  def key_for(feed)
    prefix = feed.class.name.dup
    prefix.sub! /.*:/, ''
    prefix.downcase!
    pieces = [@options[:prefix], prefix]
    feed.keys.each do |key|
      pieces << feed[key]
    end
    pieces.compact!
    pieces * ":"
  end

  def count(feed)
    @client.llen(key_for(feed))
  end

  def clear(feed)
    @client.del(key_for(feed))
  end
end
