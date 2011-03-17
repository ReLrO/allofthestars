class Stratocaster::Adapters::Redis < Stratocaster::Adapter
  def store(key, message)
    id        = message['id']
    redis_key = key_for(key)
    @client.pipelined do
      @client.lpush(redis_key, id)
      if (max = @options[:max]) > 0
        @client.ltrim(redis_key, 0, max-1)
      end
    end
  end

  def page(key, num)
    off = offset_for(num)
    @client.lrange(key_for(key), off, off + @options[:per_page] - 1) || []
  end

  def key_for(key)
    [@options[:prefix], key].compact.join(":")
  end

  def count(key)
    @client.llen(key)
  end

  def clear(key)
    @client.del(key)
  end
end
