require 'sinatra/base'
require 'allofthestars/server'
require 'digest/sha1'

module AllOfTheStars
  class Web < Sinatra::Base
    include AllOfTheStars

    get "/clusters/:id" do
      if cluster = Cluster.get(params[:id])
        cluster.to_json
      else
        not_found
      end
    end

    get "/stars/:id" do
      if star = Star.get(params[:id])
        star.to_json
      else
        not_found
      end
    end

    get "/clusters/:id/stars" do
      if cluster = Cluster.get(params[:id])
        query   = {}
        options = {}
        if q = params[:q]
          query['content'] = q
        end
        if start = params[:start]
          options["start"] = start.to_i
        end
        if type = params[:t]
          query['type'] = type
        end
        if (custom = params[:custom]).respond_to?(:keys)
          custom.each do |key, value|
            query["custom_#{key}"] = value
          end
        end
        if sort = params[:sort]
          options['sort'] = sort
        end
        resp  = cluster.search(query, options)
        stars = Star.from_search(resp)
        response["X-RiakSearch"] = resp['response'].
          slice('numFound', 'start', 'maxScore').
          inject([]) do |arr, (key, value)|
            arr << "#{key}=#{value.inspect}"
          end.join('; ')
        response["X-RiakSearchDebug"] = header_to_string(resp['responseHeader'])
        stars.to_json
      else
        not_found
      end
    end

    post "/clusters" do
      data = ActiveSupport::JSON.decode(request.body.read)
      cluster = Cluster.create(data)
      response['Location'] = "/clusters/#{cluster.id}"
      [201, cluster.to_json]
    end

    post "/clusters/:id/stars" do
      if cluster = Cluster.get(params[:id])
        data = ActiveSupport::JSON.decode(request.body.read)
        data['cluster_id'] = cluster.id
        data['created_at'] =
          case time = data['created_at'].to_s
            when /^\d+$/ then Time.at(time.to_i).utc
            else              Time.now.utc
          end

        star = nil
        if id = data['custom']['id']
          data['id'] = Digest::SHA1.hexdigest "%s:%s:%s" % [
            data['cluster_id'], data['type'], id]
          star = Star.get(data['id'])
        end

        if !star
          star  = Star.create(data)
          strat = AllOfTheStars.stratocaster
          timelines = strat.receive(star)

          response['X-Timelines'] = timelines.join(', ')
          response['Location'] = "/stars/#{star.id}"
          [201, star.to_json]
        else
          response['Location'] = "/stars/#{star.id}"
          [302, star.to_json]
        end
      else
        not_found
      end
    end

    def header_to_string(header)
      header.delete('params').each do |key, value|
        header["params.#{key}"] = value
      end
      header.inject([]) do |arr, (key, value)|
        arr << "#{key}=#{value.inspect}"
      end.join('; ')
    end
  end
end
