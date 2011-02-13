# Gravastar

I don't even know what this is going to be, yet.  Right now, it's just a
Redis/Riak testbed.  Probably not useful for anyone.

## Setup

* `brew install redis riak-search`
* `ruby app.rb` to start an IRB console
* `GRAVASTAR_ENV=irb ruby app.rb` to start a Sinatra server.
* `riaksearch start` to start riak
* `search-cmd set-schema stars db/stars.erl` to setup the
  index.
* `search-cmd install stars` to start autoindexing the stars.

## Tests

No tests.  *shrug* lol
