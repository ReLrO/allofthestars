module AllOfTheStars
  class Star
    extend Searchable
    include Toy::Store
    store :riak, AllOfTheStars.riak_client['stars']

    attribute :cluster_id, String
    attribute :type,       String
    attribute :source_url, String
    attribute :content,    String
    attribute :custom,     Hash
    attribute :created_at, Time

    default_search_options.update "sort" => "created_at desc", "index" => "stars"

    def self.publish(data)
      star      = create(data)
      feeds = AllOfTheStars.stratocaster.receive(star)
      feeds.each do |tl|
        AllOfTheStars.redis_client.publish tl, star.id
      end
      [star, *feeds]
    end

    def self.search(query = {}, options = {})
      search_riak(query, options)
    end

    def as_json(options = {})
      { :content     => content,
        :type        => type,
        :custom      => custom,
        :url         => "/stars/#{id}",
        :cluster_url => "/clusters/#{cluster_id}",
        :source_url  => source_url,
        :created_at  => created_at.iso8601
      }
    end
  end
end
