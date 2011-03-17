# Stratocaster is a system for storing and retrieving Messages in Timelines.
# A Timeline is a secondary index of Messages.  Complex SQL queries are
# replaced in favor of multiple/overlapping Timelines to filter Messages.
# Abstract adapters are used to persist the data.
class Stratocaster
  VERSION = "0.0.1"

  # Public: Each Stratocaster instance tracks which possible Timeline classes
  # it can deliver Messages to.
  attr_reader :timelines

  def initialize(*timelines)
    timelines.flatten!
    @timelines = timelines
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
  # Returns an Array of String keys of Timelines that this message was
  # delivered to.
  def receive(message)
    keys = @timelines.map do |timeline|
      timeline.deliver(message) if timeline.accept?(message)
    end
    keys.compact!
    keys
  end
end

# Load up the rest of Stratocaster.
require 'stratocaster/adapter'
require 'stratocaster/timeline'
