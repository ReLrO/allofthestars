# Gravastar

I don't even know what this is going to be, yet.  Right now, it's just a
Redis/Riak testbed.  Probably not useful for anyone.

## Setup

* `brew install redis riak-search`
* `ruby gravastar.rb` to start an IRB console
* `GRAVASTAR_ENV=irb ruby gravastar.rb` to start a Sinatra server.
* `riaksearch start` to start riak
* `search-cmd set-schema stars db/stars.erl` to setup the
  index.
* `search-cmd install stars` to start autoindexing the stars.

## USAGE

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
