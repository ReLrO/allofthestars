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

  # Public: Adds adapters to the stack of adapters for this Timeline.
  #
  # klass - One or more Adapter classes.
  #
  # Returns nothing.
  def self.adapter(*classes)
    adapters.push *classes
  end

  # Public: Determines if this message is valid for this Timeline.  This
  # should be modified in subclasses of this Timeline.
  #
  # message - The same Hash from Stratocaster#receive.
  #
  # Returns true if the Message is acceptable, or false.
  def self.accept?(message)
    if block = @accept_block || @key_block
      !!block.call(message)
    end
  end

  # Public: Sets a block condition used to determine if a message is valid
  # for this timeline.  Use the #key_format block if this is not set.
  #
  # Yields a Block with a single Message argument.
  # Returns nothing.
  def self.accept
    @accept_block = Proc.new
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
    key @key_block.call(message)
  end

  # Public: Creates a unique Timeline key using the #key_format.
  #
  # *args - Array of arguments to use to format the #key_format String.
  #
  # Returns a String.
  def self.key(*args)
    args.flatten!
    key_format % args
  end

  # Public: Either sets or gets the String format used to build the Timeline
  # key.  The format should take the same number of arguments that the
  # initializer of the custom Timeline class takes.
  #
  #     class MyTimeline < Stratocaster::Timeline
  #       key_format "type:%s:%d" do |msg|
  #         [msg['type'], msg['type_id']]
  #       end
  #     end
  #
  #     tl = Timeline.new('object', 5)
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

  # Returns the String key of this Timeline instance.
  attr_reader :key

  # Returns the Adapter used for queries on this Timeline instance.
  attr_reader :default_adapter

  # Initializes a new Timeline instance with this Message for querying
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
