class Stratocaster::Adapters::Memory < Stratocaster::Adapter
  def store(keys, message)
    id  = message['id'].to_s
    keys.each do |key|
      (@client[key] ||= []).unshift id
    end
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
