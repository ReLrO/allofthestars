module AllOfTheStars
  module Searchable
    def default_search_options
      @default_search_options ||= {'q.op' => 'and', 'rows' => 50}
    end

    def search_riak(query = {}, options = {})
      query, options = merge_query_and_options(query, options)
      store.client.client.search(query, options)
    end

    def merge_query_and_options(query, options)
      options = default_search_options.merge(options)
      query   = query.inject([]) do |arr, (key, value)|
        value.gsub! /"/, ''
        arr << %(#{key}:"#{value}")
      end.join(" AND ")
      [query, options]
    end

    # Converts the Riak Search results that Ripple gives us into STARS.
    def from_search(resp)
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
