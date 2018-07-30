ENV['RACK_ENV'] = 'test'

require "./form"

require "byebug"
require "test/unit"
require "mocha"
require 'mocha/test_unit'
require "rack/test"

class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_post
    SecureRandom.stubs(:uuid).returns("118db8f6-b677-4eda-b564-7afeaee86ee6")
    post "/responses", {redirect_url: "https://example.org/:response_id", response: {name: "Paul", email: "paul@tito.io", comments: "Stuff"}}
    assert last_response.redirect?
    assert last_response.location = "https://example.org/118db8f6-b677-4eda-b564-7afeaee86ee6"
  end
end