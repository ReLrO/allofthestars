module AllOfTheStars
  class Cluster
    extend Searchable
    include Toy::Store, ActiveModel::Callbacks

    store :riak, AllOfTheStars.riak_client['clusters']

    attribute :name,  String
    attribute :email, String

    default_search_options.update "sort" => "name", "index" => "clusters"

    before_create :scrub_attributes

    def search(query={}, options = {})
      query['cluster_id'] = id
      AllOfTheStars::Star.search(query, options)
    end

    def self.by_email(email)
      search_riak('email' => email)
    end

    def as_json(options = {})
      url_path = "/clusters/#{id}"
      {
        :name  => name,
        :email => email,
        :url   => url_path,
        :stars_url => "#{url_path}/stars"
      }
    end

  private
    def scrub_attributes
      self.name ||= id
      self.id     = id.to_s.parameterize
    end
  end
end
