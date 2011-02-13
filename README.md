# Gravastar

I don't even know what this is going to be, yet.  Right now, it's just a
Riak Search testbed.  Probably not useful for anyone.

## Setup

Setup the rubies:

    gem install bundler
    bundle install

And the Riaks:

    brew install riak-search # or equivalent
    riaksearch start

    # setup the search schema
    search-cmd set-schema stars db/stars.erl
    search-cmd set-schema clusters db/clusters.erl

    # setup the automatic riak kv => riak search hooks
    search-cmd install stars
    search-cmd install clusters

## USAGE

You can start an irb console to play around:

    ruby gravastar.rb

If you want to access it over HTTP, start the sinatra API server:

    GRAVASTAR_ENV=production ruby gravastar.rb

All JSON API for now.  The actual serialization and fields will likely
change.

* create a cluster
  * `POST /clusters`
* create a star
  * `POST /clusters/:id/stars`
* get a cluster
  * `GET /clusters/:id`
* get a star
  * `GET /stars/:id`
* get stars in a cluster
  * `GET /clusters/:id/stars`
  * `?q=blah` - search content
  * `?t=Campfire` - filter by type
  * `?custom[foo]` - filter by custom field
  * `?start` - the starting result of the query (pagination)

## Tests

No tests.  *shrug* lol
