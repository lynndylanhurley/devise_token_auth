require 'test_helper'

class DeviseTokenAuth::UrlTest < ActiveSupport::TestCase
	describe "DeviseTokenAuth::Url#generate" do
	  test 'URI fragment should appear at the end of URL' do
	    params = {client_id: 123}
	    url = 'http://example.com#fragment'
	    assert_equal DeviseTokenAuth::Url.send(:generate, url, params), "http://example.com?client_id=123#fragment"
	  end
	end
end