# A Feed is responsible for deciding which Messages it can receive,
# storing the Message IDs in the Adapters, and retrieving them.
# Feeds process messages into Feed#data, a hash with just enough information
# for an adapter to store it.  Feeds should be subclassed to define custom
# callbacks that handle received messages and acceptance conditions.
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
    block = @accept_block || (@receive_block.arity == 1 && @receive_block)
    value = block && block.call(message)
    value.respond_to?(:size) ? value.size > 0 : !!value
  end

  # Public: Sets a block condition used to determine if a message is valid
  # for this feed.  Use the #on_receive block if this is not set.
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
  # Returns an Array of Feeds.
  def self.deliver(message)
    feeds = feeds_for(message)
    adapters.each do |adapter|
      adapter.store(feeds, message)
    end
    feeds
  end

  # Public: Scans the message for the instances of this Feed that this message
  # will be delivered to.
  #
  # Returns an Array of Feed instances.
  def self.feeds_for(message)
    feeds = []
    if @receive_block.arity == 2
      @receive_block.call(message, feeds)
      feeds.map { |data| new(data) }
    else
      feeds << new(@receive_block.call(message))
    end
  end

  # Public: Sets the block that is used to turn a received message into
  # the Feed data that adapters use.  The block yields either just the message,
  # or a message and an array if multiple feeds are used for a single message.
  #
  #     class UserFeed < Stratocaster::Feed
  #       on_receive do |msg|
  #         {:user => msg[:user_id]}
  #       end
  #     end
  #
  #     class WordFeed < Stratocaster::Feed
  #       on_receive do |msg, feeds|
  #         msg.content.split(' ').each do |word|
  #           feeds << {:word => word}
  #         end
  #       end
  #     end
  #
  # Returns nothing.
  def self.on_receive
    @receive_block = Proc.new
  end

  attr_reader :data
  attr_reader :options

  # Initializes a new Feed instance with this Message for querying
  # purposes.
  #
  # message - The same Hash from Stratocaster#receive.
  # options - Optional Hash (reserved for future use).
  def initialize(data = {}, options = {})
    @data    = data
    @options = options
  end

  # Public: Queries the default Adapter for the _n_ page of Message IDs.
  #
  # num - A Fixnum page number.
  #
  # Returns an Array of Message IDs.
  def page(num)
    adapter.page(self, num)
  end

  # Public: Counts the number of Messages in this Feed.
  #
  # Returns a Fixnum size.
  def count
    adapter.count(self)
  end

  # Public: Clears the Messages in this Feed.
  #
  # Returns nothing.
  def clear
    adapter.clear(self)
  end

  # Public: Accesses a value from the Feed#data by key.
  #
  # Returns a String or Fixnum, typically.
  def [](key)
    @data[key]
  end

# Ruby 1.9 has ordered hashes
if RUBY_VERSION =~ /^1\.9/
  def keys
    @data.keys
  end

else
  def keys
    @data.keys.sort
  end
end

  def adapter
    @adapter ||= options[:adapter] || self.class.adapters.first
  end
end
