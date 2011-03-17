# An Adapter handles the dirty job of actually persisting Message IDs
# and retrieving them.
class Stratocaster::Adapter
  class << self
    # A global default page size for Timelines.
    attr_accessor :per_page,

    # A global default total size for Timelines.  Not always used by
    # Adapters.
                  :max
  end

  self.per_page = 50
  self.max      = 300

  # Subclasses get the same defaults.
  def self.inherited(klass)
    klass.per_page = self.per_page
    klass.max      = self.max
  end

  # Returns a reference to the raw DB driver.
  attr_reader :client

  # Returns a Hash of options to customize the Timeline behavior.
  # per_page - A Fixnum specifying the page size for individual query
  #            results.
  attr_reader :options

  def initialize(client, options = {})
    @client  = client
    @options = options
    @options[:per_page] ||= self.class.per_page
    @options[:max]      ||= self.class.max
  end

  # Public: Stores the given Message ID in the Timeline identified by
  # the given key.
  #
  # keys    - An Array of String keys of Timelines.
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns nothing.
  def store(keys, message)
    raise NotImplementedError
  end

  # Public: Queries the Timeline for a page of Message IDs.
  #
  # key - The String key of the Timeline.
  # num - The Fixnum page number.
  #
  # Returns an Array of Message IDs.
  def page(key, num)
    raise NotImplementedError
  end

  # Public: Counts the Messages stored in a Timeline.
  #
  # key - The String key of the Timeline.
  #
  # Returns a Fixnum size.
  def count(key)
    raise NotImplementedError
  end

  # Public: Clears all Messages stored in a Timeline.
  #
  # key - The String key of the Timeline.
  #
  # Returns nothing.
  def clear(key)
    raise NotImplementedError
  end

  # Calculates the offset for the given page.
  #
  # page_num - The Fixnum page number.
  #
  # Returns a Fixnum offset.
  def offset_for(page_num)
    [page_num-1, 0].max * @options[:per_page]
  end

  def dup
    self.class.new(@client, @options)
  end
end

module Stratocaster::Adapters
  autoload :Memory, 'stratocaster/adapters/memory'
  autoload :Redis,  'stratocaster/adapters/redis'
end
