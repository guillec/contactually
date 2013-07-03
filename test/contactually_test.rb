require "test_helper"
require "contactually"
require "curb"
require "minitest/mock"

describe "Contactually API method calls samples" do

  before do
    @api_key      = "i8d6k1y1hjbrbh6qochplf3vkxtapqul"
    @contactually = Contactually::API.new(@api_key)

    #Fake Response
    FakeResponse = Struct.new(:body_str)
    @response    = FakeResponse.new("{}")
    @mock        = MiniTest::Mock.new
    @mock.expect :body_str, @response.body_str
  end

  it "can call a contact" do

    #Curl.stub(:post, @mock) do
      @contactually.post_contact
    #end

    #assert @mock.verify
  end

end

describe "Method Builder" do
  before do
    @api_key      = "i8d6k1y1hjbrbh6qochplf3vkxtapqul"
    @contactually = Contactually::API.new(@api_key)
  end

  it "should return a http_method and contactually method" do
    assert @contactually.send(:get_methods, :post_contact) == ["post", "contact"]
  end

  it "should build a uri with no id" do
    test_method = "contact"
    test_uri = "https://www.contactually.com/api/v1/#{test_method}.json"
    assert @contactually.send(:build_uri, "contact") == test_uri
  end

  it "should build a uri with id" do
    test_method = "contact"
    args_hash   = { id: 1 }
    test_uri = "https://www.contactually.com/api/v1/#{test_method}/#{args_hash[:id]}.json"
    assert @contactually.send(:build_uri, "contact", args_hash) == test_uri
  end

end
