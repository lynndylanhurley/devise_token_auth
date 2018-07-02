# Testing

In order to authorize a request when testing your API you will need to pass the four headers through with your request, the easiest way to gain appropriate values for those headers is to use `resource.create_new_auth_token` e.g.

```Ruby
  request.headers.merge! resource.create_new_auth_token
  get '/api/authenticated_resource'
  # success
```

Check #75 if you have any problem or doubt.

## Testing with Rspec

### (a) General Request Specs

Below are some generic examples which may assist in helping you devise (pun intended) your own tests:

```ruby
# I've called it authentication_test_spec.rb and placed it in the spec/requests folder
require 'rails_helper'
include ActionController::RespondWith

# The authentication header looks something like this:
# {"access-token"=>"abcd1dMVlvW2BT67xIAS_A", "token-type"=>"Bearer", "client"=>"LSJEVZ7Pq6DX5LXvOWMq1w", "expiry"=>"1519086891", "uid"=>"darnell@konopelski.info"}

describe 'Whether access is ocurring properly', type: :request do
  before(:each) do
    @current_user = FactoryBot.create(:user)
    @client = FactoryBot.create :client
  end

  context 'context: general authentication via API, ' do
    it "doesn't give you anything if you don't log in" do
      get api_client_path(@client)
      expect(response.status).to eq(401)
    end

    it 'gives you an authentication code if you are an existing user and you satisfy the password' do
      login
      # puts "#{response.headers.inspect}"
      # puts "#{response.body.inspect}"
      expect(response.has_header?('access-token')).to eq(true)
    end

    it 'gives you a status 200 on signing in ' do
      login
      expect(response.status).to eq(200)
    end

    it 'gives you an authentication code if you are an existing user and you satisfy the password' do
      login
      expect(response.has_header?('access-token')).to eq(true)
    end

    it 'first get a token, then access a restricted page' do
      login
      auth_params = get_auth_params_from_login_response_headers(response)
      new_client = FactoryBot.create(:client)
      get api_find_client_by_name_path(new_client.name), headers: auth_params
      expect(response).to have_http_status(:success)
    end

    it 'deny access to a restricted page with an incorrect token' do
      login
      auth_params = get_auth_params_from_login_response_headers(response).tap do |h|
        h.each do |k, _v|
          if k == 'access-token'
            h[k] = '123'
          end end
      end
      new_client = FactoryBot.create(:client)
      get api_find_client_by_name_path(new_client.name), headers: auth_params
      expect(response).not_to have_http_status(:success)
    end
  end

  RSpec.shared_examples 'use authentication tokens of different ages' do |token_age, http_status|
    let(:vary_authentication_age) { token_age }

    it 'uses the given parameter' do
      expect(vary_authentication_age(token_age)).to have_http_status(http_status)
    end

    def vary_authentication_age(token_age)
      login
      auth_params = get_auth_params_from_login_response_headers(response)
      new_client = FactoryBot.create(:client)
      get api_find_client_by_name_path(new_client.name), headers: auth_params
      expect(response).to have_http_status(:success)

      allow(Time).to receive(:now).and_return(Time.now + token_age)

      get api_find_client_by_name_path(new_client.name), headers: auth_params
      response
    end
  end

  context 'test access tokens of varying ages' do
    include_examples 'use authentication tokens of different ages', 2.days, :success
    include_examples 'use authentication tokens of different ages', 5.years, :unauthorized
  end

  def login
    post api_user_session_path, params:  { email: @current_user.email, password: 'password' }.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
  end

  def get_auth_params_from_login_response_headers(response)
    client = response.headers['client']
    token = response.headers['access-token']
    expiry = response.headers['expiry']
    token_type = response.headers['token-type']
    uid = response.headers['uid']

    auth_params = {
      'access-token' => token,
      'client' => client,
      'uid' => uid,
      'expiry' => expiry,
      'token_type' => token_type
    }
    auth_params
  end
end

```

### (b) How to create an authorization header from Scratch

```ruby
require 'rails_helper'
include ActionController::RespondWith

def create_auth_header_from_scratch
  # You need to set up factory bot to use this method
  @current_user = FactoryBot.create(:user)
  # create client id and token
  client_id = SecureRandom.urlsafe_base64(nil, false)
  token     = SecureRandom.urlsafe_base64(nil, false)

  # store client + token in user's token hash
  @current_user.tokens[client_id] = {
    token: BCrypt::Password.create(token),
    expiry: (Time.now + 1.day).to_i
  }

  # Now we have to pretend like an API user has already logged in.
  # (When the user actually logs in, the server will send the user
  # - assuming that the user has  correctly and successfully logged in
  # - four auth headers. We are to then use these headers to access
  # things which are typically restricted
  # The following assumes that the user has received those headers
  # and that they are then using those headers to make a request

  new_auth_header = @current_user.build_auth_header(token, client_id)

  puts 'This is the new auth header'
  puts new_auth_header.to_s

  # update response with the header that will be required by the next request
  puts response.headers.merge!(new_auth_header).to_s
end
```

### Further Examples of Request Specs

* https://gist.github.com/blaze182/3a59a6af8c6a7aaff7bf5f8078a5f2b6
* https://gist.github.com/niinyarko/f146f24a50125d55396f63043a2696e7
