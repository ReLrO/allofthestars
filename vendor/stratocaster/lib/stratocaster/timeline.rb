# A Timeline is responsible for deciding which Messages it can receive,
# storing the Message IDs in the Adapters, and retrieving them.
# Timelines should be subclassed to define custom key names and
# acceptance conditions.
class Stratocaster::Timeline
  class << self
    attr_writer :adapters
  end

  self.adapters = []

  # Public: A Timeline can store Messages in multiple Adapters.  Each
  # Adapter is for a specific data store (Redis, MySQL, etc).
  def self.adapters
    @adapters ||= []
  end

  # Public: Determines if this message is valid for this Timeline.  This
  # should be modified in subclasses of this Timeline.
  #
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns true if the Message is acceptable, or false.
  def self.accept?(message)
    true
  end


  # Public: Delivers the Message to this Timeline's adapters.
  #
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns the String key of the Timeline.
  def self.deliver(message)
    key = key_for(message)
    adapters.each do |adapter|
      adapter.store(key, message)
    end
    key
  end

  # Public: Creates a unique Timeline key.  The key is used to identify
  # where the Message is added in the Adapter.  In Redis, it'd be used
  # to build the key of a Redis List.  The generated key of the same
  # Message in two Timelines are probably going to be different.
  #
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns a String key.
  def self.key_for(message)
    "actor:#{message['actor']['id']}"
  end

  # Returns the String key of this Timeline instance.
  attr_reader :key

  # Returns the Adapter used for queries on this Timeline instance.
  attr_reader :default_adapter

  # Initializes a new Timeline instance with this Message for querying
  # purposes.
  #
  # message - The same Hash from Stratocaster#receive.
  # options - Optional Hash (reserved for future use).
  def initialize(message, options = {})
    @key = self.class.key_for(message)
    @default_adapter = self.class.adapters.first
  end

  # Public: Queries the default Adapter for the _n_ page of Message IDs.
  #
  # num - A Fixnum page number.
  #
  # Returns an Array of Message IDs.
  def page(num)
    default_adapter.page(@key, num)
  end

  # Public: Counts the number of Messages in this Timeline.
  #
  # Returns a Fixnum size.
  def count
    default_adapter.count(@key)
  end

  # Public: Clears the Messages in this Timeline.
  #
  # Returns nothing.
  def clear
    default_adapter.clear(@key)
  end
end
