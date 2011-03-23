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
  # message - A Hash:
  #           id - The String Message ID.
  #           created_at - The Time the Message was created.
  #           actor - A Hash with at least an `id` property to identify the
  #                   user that created the message.
  #           payload - A Hash holding custom values for the Message.
  #
  # Returns an Array of String keys of Feeds that this message was
  # delivered to.
  def receive(message)
    keys = @feeds.map do |feed|
      feed.deliver(message) if feed.accept?(message)
    end

    keys.flatten!
    keys.compact!
    keys
  end
end

# Load up the rest of Stratocaster.
require 'stratocaster/adapter'
require 'stratocaster/feed'
