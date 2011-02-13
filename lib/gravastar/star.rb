module Gravastar
  class Star
    DEFAULT_SEARCH_OPTIONS = {"q.op" => "and", "sort" => "stars.created_at", "rows" => 50}

    include Toy::Store
    store :riak, Riak::Client.new['stars']

    attribute :cluster_id, String
    attribute :type,       String
    attribute :url,        String
    attribute :content,    String
    attribute :custom,     Hash
    attribute :created_at, Time

    def self.search(query = {}, options = {})
      options = DEFAULT_SEARCH_OPTIONS.merge(options)
      query   = query.inject([]) do |arr, (key, value)|
        value.gsub! /"/, ''
        arr << %(#{key}:"#{value}")
      end.join(" AND ")
      store.client.client.search(query, options)
    end

    # Converts the Riak Search results that Ripple gives us into STARS.
    def self.from_search(resp)
      resp['response']['docs'].map do |doc|
        s = new(:id => doc['id'])
        doc['fields'].each do |key, value|
          case key
            when /^custom_(.*)/
              s.custom[$1] = value
            else
              s[key] = value
          end
        end
        s
      end
    end
  end
end
