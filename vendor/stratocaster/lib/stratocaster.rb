# Stratocaster is a system for storing and retrieving Messages in Feeds.
# A Feed is a secondary index of Messages.  Complex SQL queries are
# replaced in favor of multiple/overlapping Feeds to filter Messages.
# Abstract adapters are used to persist the data.
class Stratocaster
  VERSION = "0.0.1"

  # Public: Each Stratocaster instance tracks which possible Feed classes
  # it can deliver Messages to.
  attr_reader :feeds

  def initialize(*feeds)
    feeds.flatten!
    @feeds = feeds
  end

  # Public: Processes a received Message.  Since Stratocaster only stores the
  # ID (usually, depends on the adapter), assume that the message is already
  # stored in some other ActiveModel-compatible store (ActiveRecord, ToyStore,
  # etc).
  #
  # message - An ActiveModel-compatible object.  Needs to respond to #id and
  #           #created_at (depending on the Adapter).
  #
  # Returns an Array of  Feeds that this message was delivered to.
  def receive(message)
    feeds = @feeds.map do |feed|
      feed.deliver(message) if feed.accept?(message)
    end

    feeds.flatten!
    feeds.compact!
    feeds
  end
end

# Load up the rest of Stratocaster.
require 'stratocaster/adapter'
require 'stratocaster/feed'
