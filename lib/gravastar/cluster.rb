module Gravastar
  class Cluster
    include Toy::Store, ActiveModel::Callbacks
    store :redis, Redis.new(:db => 1)

    attribute :name,  String
    attribute :email, String

    before_create :scrub_attributes

    def search(query={}, options = {})
      query['stars.cluster_id'] = id
      Gravastar::Star.search(query, options)
    end

  private
    def scrub_attributes
      self.name ||= id
      self.id     = id.to_s.parameterize
    end
  end
end
