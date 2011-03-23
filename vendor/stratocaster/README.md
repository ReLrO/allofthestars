# Stratocaster

## Overview

Stratocaster is a system for storing and retrieving messages on
feeds. A message can contain any arbitrary payload. A feed is a
filtered stream of messages.  Complex querying is replaced in favor of
creating multiple feeds as filters for the messages.  Stratocaster
uses abstract adapters to persist the data, instead of being bound to
any one type of data store.

Some of these ideas came from the way [FriendFeed uses MySQL to store
schemaless objects][friendfeed].

[friendfeed]: http://bret.appspot.com/entry/how-friendfeed-uses-mysql

### Message

A Message is a schema-less entity intended to be delivered to one or
more feeds.  Stratocaster will take any ActiveModel compatible model
(ActiveRecord, [ToyStore][toys], etc) and convert it to a Hash with
these required keys:

* `id` - the unique identifier.
* `created_at` - the timestamp the Message was created.
* `actor` - an object with at least an `id` property to identify the
  user that created the message.
* `payload` - an object with custom values for the Message.

A Message would look something like this as a Ruby hash:

    {'id'         => 123,
     'created_at' => <time>,
     'actor'      => {'id' => 12, 'name' => 'bob'},
     'payload'    => {'repository' => {'id' => 1, 'name' => 'user/repo'},
                      'title' => '...', ...},
     ...
    }

[toys]: https://github.com/newtoy/toystore

### Feed

A Feed is a pre-computed view of messages that meet a certain
criteria.  A Stratocaster instance knows which possible feeds a
message can be delivered to.  As each message comes in, Stratocaster
finds the feeds that are applicable to the message.

Each feed is responsible for persisting the Message by its Id and
retrieving the Ids in pages.  These Ids are then passed to the data
store that Messages are persisted.

## Ruby API

First, you need to define the Feeds:

    class RepositoryFeed < Stratocaster::Feed
      # Feeds can use multiple adapters
      adapter :redis, :host => '...', :default => true
      adapter :mysql, ...

      # This method is used to determine if this Feed should receive
      # the incoming Message.
      def self.accept?(message)
        !message.repository
      end

      def initialize(repository_id)
        @key = "repo:#{repository_id}"
      end

      def self.deliver(message)
        adapters.each do |adapter|
          adapter.deliver(message.id)
        end
      end
    end

Create an instance of Stratocaster to start processing messages.

    strat = Stratocaster.new PublicFeed, RepositoryFeed, ...

    # Add or remove them on the instance.
    strat.feeds << ActorFeed
    strat.feeds.unshift RecipientFeed

Now, you can start processing messages!

    strat.receive(message)

Internally, this calls:

    strat.feeds.each do |feed|
      feed.deliver(message) if feed.accept?(message)
    end

To query a feed, create an instance of the Feed.

    repo = Repository.find(1)
    redis_feed = RepositoryFeed.new(repo.id, :per_page => 50)

    # Get the first page of the most recent messages.
    redis_feed.page(1) # uses the default adapter
    # => [12, 26, 230]

    # specify the adapter
    mysql_feed = RepositoryFeed.new(repo.id, :adapter => :mysql)

    # or change it on an existing feed
    redis_feed.adapter = :mysql
