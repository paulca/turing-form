require "sinatra"
require "sinatra/cross_origin"
require "sinatra/json"
require "sinatra/respond_with"
require "redis"

configure do
  enable :cross_origin
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

def connect_to_redis
  $redis = Redis.new(url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379")
end

def set_content_type
  content_type "application/json"
end

def get_response
  $redis.get(params[:response_id])
end

def get_unique_id
  SecureRandom.uuid
end

def save_response(params)
  id = get_unique_id
  $redis.set(id, params.to_json)
  id
end

def swap_id_and_redirect_back(id)
  redirect params[:redirect_url].gsub(":response_id", id)
end

def save_html_response
  id = save_response(params[:response])
  swap_id_and_redirect_back(id)
end

def save_json_response
  response = JSON.parse(request.body.read)
  id = save_response(response["response"])
  json({id: id, response: response})
end

connect_to_redis

get "/responses/:response_id" do
  set_content_type
  get_response
end

post "/responses" do
  
  logger.info params
  respond_with :create, name: "create" do |wants|
    wants.html { save_html_response }
    wants.json { save_json_response }
  end
end

options "*" do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end