include Gravastar

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

post "/clusters" do
  data = ActiveSupport::JSON.decode(request.body.read)
  cluster = Cluster.create(data['cluster'])
  response['Location'] = "/clusters/#{cluster.id}"
  [201, cluster.to_json]
end

post "/clusters/:id/stars" do
  if cluster = Cluster.get(params[:id])
    data = ActiveSupport::JSON.decode(request.body.read)['star']
    data['cluster_id'] = cluster.id
    data['created_at'] = Time.now.utc
    star = Star.create(data)
    response['Location'] = "/stars/#{star.id}"
    [201, star.to_json]
  else
    not_found
  end
end
