# A Feed is responsible for deciding which Messages it can receive,
# storing the Message IDs in the Adapters, and retrieving them.
# Feeds should be subclassed to define custom key names and
# acceptance conditions.
class Stratocaster::Feed
  class << self
    attr_writer :adapters
  end

  self.adapters = []

  # Public: A Feed can store Messages in multiple Adapters.  Each
  # Adapter is for a specific data store (Redis, MySQL, etc).
  def self.adapters
    @adapters ||= []
  end

  # Public: Adds adapters to the stack of adapters for this Feed.
  #
  # klass - One or more Adapter classes.
  #
  # Returns nothing.
  def self.adapter(*classes)
    adapters.push *classes
  end

  # Public: Determines if this message is valid for this Feed.  This
  # should be modified in subclasses of this Feed.
  #
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns true if the Message is acceptable, or false.
  def self.accept?(message)
    block = @accept_block || (@key_block.arity == 1 && @key_block)
    value = block && block.call(message)
    value.respond_to?(:size) ? value.size > 0 : !!value
  end

  # Public: Sets a block condition used to determine if a message is valid
  # for this feed.  Use the #key_format block if this is not set.
  #
  # Yields a Block with a single Message argument.
  # Returns nothing.
  def self.accept
    @accept_block = Proc.new
  end

  # Public: Delivers the Message to this Feed's adapters.
  #
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns an Array of String keys of Feeds.
  def self.deliver(message)
    keys = keys_for(message)
    adapters.each do |adapter|
      adapter.store(keys, message)
    end
    keys
  end

  # Public: Creates a unique Feed key.  The key is used to identify
  # where the Message is added in the Adapter.  In Redis, it'd be used
  # to build the key of a Redis List.  The generated key of the same
  # Message in two Feeds are probably going to be different.
  #
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns an Array of String keys.
  def self.keys_for(message)
    keys = []
    if @key_block.arity == 2
      @key_block.call(message, keys)
      keys.map { |k| key *k }
    else
      keys << key(*@key_block.call(message))
    end
  end

  # Public: Creates a unique Feed key using the #key_format.
  #
  # *args - Array of arguments to use to format the #key_format String.
  #
  # Returns a String.
  def self.key(*args)
    args.flatten!
    key_format % args
  end

  # Public: Either sets or gets the String format used to build the Feed
  # key.  The format should take the same number of arguments that the
  # initializer of the custom Feed class takes.
  #
  #     class MyFeed < Stratocaster::Feed
  #       key_format "type:%s:%d" do |msg|
  #         [msg['type'], msg['type_id']]
  #       end
  #     end
  #
  #     tl = Feed.new('object', 5)
  #     tl.key # => "type:object:5"
  #
  # str - Optional String that resets the key format.
  #
  # Returns the String format.
  def self.key_format(str = nil)
    if str
      @key_format = str
      @key_block  = Proc.new
    end

    @key_format
  end

  # Returns the String key of this Feed instance.
  attr_reader :key

  # Returns the Adapter used for queries on this Feed instance.
  attr_reader :default_adapter

  # Initializes a new Feed instance with this Message for querying
  # purposes.
  #
  # message - The same Hash from Stratocaster#receive.
  # options - Optional Hash (reserved for future use).
  def initialize(*args)
    @key = self.class.key(*args)
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

  # Public: Counts the number of Messages in this Feed.
  #
  # Returns a Fixnum size.
  def count
    default_adapter.count(@key)
  end

  # Public: Clears the Messages in this Feed.
  #
  # Returns nothing.
  def clear
    default_adapter.clear(@key)
  end
end
