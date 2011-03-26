class Stratocaster::Adapters::Memory < Stratocaster::Adapter
  def store(feeds, message)
    id  = message['id'].to_s
    feeds.each do |feed|
      key = key_for(feed)
      (@client[key] ||= []).unshift id
    end
  end

  def page(feed, num)
    arr = @client[key_for(feed)]
    return [] if !arr
    offset = offset_for(num)
    arr[offset...@options[:per_page]*num]
  end

  def count(feed)
    if arr = @client[key_for(feed)]
      arr.size
    else
      0
    end
  end

  def clear(feed)
    @client.delete(key_for(feed))
  end

  def key_for(feed)
    feed.data
  end
end
