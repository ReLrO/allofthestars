module Gravastar
  class Cluster
    include Toy::Store, ActiveModel::Callbacks
    store :riak, Riak::Client.new['users']

    attribute :name,  String
    attribute :email, String

    before_create :scrub_attributes

    def search(query={}, options = {})
      query['stars.cluster_id'] = id
      Gravastar::Star.search(query, options)
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
