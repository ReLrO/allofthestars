module Gravastar
  class Star
    include Toy::Store
    store :riak, Riak::Client.new['stars']

    attribute :cluster_id, String
    attribute :type,       String
    attribute :url,        String
    attribute :content,    String
    attribute :custom,     Hash
    attribute :created_at, Time
  end
end
