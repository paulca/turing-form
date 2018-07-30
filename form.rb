require "sinatra"
require "redis"

redis = Redis.new(url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379")

get "/responses/:response_id" do
  content_type "application/json"
  response = redis.get(params[:response_id])
  response
end

post "/responses" do
  unique_id = SecureRandom.uuid
  redis.set(unique_id, params[:response].to_json)

  redirect params[:redirect_url].gsub(":response_id", unique_id)
end