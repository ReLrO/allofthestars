class Stratocaster::Adapters::Memory < Stratocaster::Adapter
  def store(key, message)
    id = message['id']
    (@client[key] ||= []).unshift id.to_s
  end

  def page(key, num)
    arr = @client[key]
    return [] if !arr
    offset = offset_for(num)
    arr[offset...@options[:per_page]*num]
  end

  def count(key)
    if arr = @client[key]
      arr.size
    else
      0
    end
  end

  def clear(key)
    @client.delete(key)
  end
end
