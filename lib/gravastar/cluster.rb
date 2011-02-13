module Gravastar
  class Cluster
    include Toy::Store
    store :redis, Redis.new(:db => 1)

    attribute :name,  String
    attribute :email, String
  end
end
