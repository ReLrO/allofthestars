require 'time'
require 'set'

# Due to Riak's distributed nature, we can't efficiently get messages from a
# list of IDs.  Instead, we'll store the whole list in Riak, and rely on
# conflict resolution to keep things consistent.  Items are stored in a two
# element tuple of [TIME, MESSAGE].  Riak serializes the whole thing to json.
#
# TODO: Allow configurable sortable field.
class Stratocaster::Adapters::Riak < Stratocaster::Adapter
  def initialize(client, options = {})
    super
    @options[:time_field] ||= 'created_at'
    @options[:id_field]   ||= 'id'
  end

  def store(feeds, message)
    time = message[@options[:time_field]].to_i
    max  = @options[:max]
    max  = nil if max < 1
    feeds.each do |feed|
      obj = fetch(key_for(feed))
      obj.data ||= []
      obj.data.unshift([time, message])
      if max
        obj.data.pop while obj.data.size > max
      end
      obj.store
    end
  end

  def page(feed, num)
    obj = fetch(key_for(feed))
    return [] if obj.data.blank?
    offset = offset_for(num)
    items  = obj.data[offset...@options[:per_page]*num]
    items.map! { |item| item.pop }
  end

  def key_for(feed)
    prefix = feed.class.name.dup
    prefix.sub! /.*:/, ''
    prefix.downcase!
    pieces = [prefix]
    feed.keys.each do |key|
      pieces << feed[key]
    end
    pieces.compact!
    pieces * "."
  end

  def fetch(key)
    obj = @client.get_or_new(key)
    obj = settle_conflict(obj) if obj.conflict?
    obj
  end

  def count(feed)
    obj = fetch(key_for(feed))
    if arr = obj.data
      arr.size
    else
      0
    end
  end

  def clear(feed)
    @client.delete(key_for(feed))
  end

  def settle_conflict(obj)
    id_field = @options[:id_field]
    set = Set.new
    new_obj = @client.new(obj.key)
    new_obj.vclock = obj.vclock
    new_obj.data = []
    obj.siblings.each do |sibling|
      sibling.data.each do |(time, hash)|
        id = hash[id_field]
        next if set.include?(id)
        set << id
        new_obj.data << [time, hash]
      end
    end
    new_obj.data.sort! do |x, y|
      y[0] <=> x[0]
    end
    new_obj.store
    new_obj
  end
end

# Riak-client v0.8.3 doesn't define this
class FalseClass
  def blank?() true end
end
