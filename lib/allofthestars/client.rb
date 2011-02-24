require 'faraday'
require 'yajl'

module AllOfTheStars
  class Client
    Builder = Faraday::Builder.new do |b|
      b.request  :yajl
      b.adapter  :excon
      b.response :yajl
    end

    attr_reader :http

    def initialize(url = 'http://allofthestars.com')
      @http = Faraday::Connection.new(url, :builder => Builder)
    end

    def cluster(id)
      @http.get("/clusters/#{id}").body
    end

    def star(id)
      @http.get("/stars/#{id}").body
    end

    def stars(cluster_id, options = {})
      @http.get("/clusters/#{cluster_id}/stars").body
    end

    # id   - String Key for the Cluster.
    # data - Optional Hash of attributes.
    #        :name  - String name of the Cluster.  Uses the Key by
    #                 default.
    #        :email - String email of the Cluster.
    def add_cluster(id, data = {})
      data['id'] = id
      @http.post("/clusters", data)
    end

    # cluster_id - String Key for the Cluster.
    # data       - Hash of attributes for the Star.
    #              :type       - String Star type (Twitter/Campfire, etc)
    #              :content    - String content of the Star.
    #              :source_url - String permalink of the Star.
    #              :custom     - Optional open Hash of attributes.
    def add_star(cluster_id, data = {})
      @http.post("/clusters/#{cluster_id}/stars", data)
    end

    def inspect
      %(#<#{self.class.name} #{@http.build_url(nil).to_s}>)
    end
  end
end
