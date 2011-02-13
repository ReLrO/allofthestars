module Gravastar
  class Cluster
    include Toy::Store
    store :redis, Redis.new(:db => 1)

    attribute :name,  String
    attribute :email, String

    def search(query=nil, options = {})
      Gravastar::Star.search(%(stars.cluster_id:"#{id}" #{query}).strip, options)
    end

    def search_results(query=nil, options = {})
      Gravastar::Star.search_results(%(stars.cluster_id:"#{id}" #{query}).strip, options)
    end
  end
end
