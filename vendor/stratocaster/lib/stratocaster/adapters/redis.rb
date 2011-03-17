class Stratocaster::Adapters::Redis < Stratocaster::Adapter
  def store(keys, message)
    id = message['id'].to_s
    @client.pipelined do
      keys.each do |key|
        redis_key = key_for(key)
        @client.lpush(redis_key, id)
        if (max = @options[:max]) > 0
          @client.ltrim(redis_key, 0, max-1)
        end
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
