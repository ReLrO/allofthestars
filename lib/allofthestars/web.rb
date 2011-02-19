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
      query['stars.content'] = q
    end
    if start = params[:start]
      options["start"] = start.to_i
    end
    if type = params[:t]
      query['stars.type'] = type
    end
    if (custom = params[:custom]).respond_to?(:keys)
      custom.each do |key, value|
        query["stars.custom_#{key}"] = value
      end
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
    data['created_at'] = Time.now.utc
    star = Star.create(data)
    response['Location'] = "/stars/#{star.id}"
    [201, star.to_json]
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
