module Gravastar
  class Cluster
    include Toy::Store
    store :redis, Redis.new(:db => 1)

    attribute :name,  String
    attribute :email, String

    def search(query=nil, options = {})
      query['stars.cluster_id'] = id
      Gravastar::Star.search(query, options)
    end
  end
end
