module Gravastar
  class Star
    include Toy::Store
    store :riak, Riak::Client.new['stars']

    attribute :cluster_id, String
    attribute :type,       Hash
    attribute :url,        String
    attribute :content,    String
    attribute :created_at, Time
  end
end
