# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  describe User do
    describe 'serialization' do
      test 'hash should not include sensitive info' do
        @resource = build(:user)
        refute @resource.as_json[:tokens]
      end
    end

    describe 'creation' do
      test 'save fails if uid is missing' do
        @resource = User.new
        @resource.uid = nil
        @resource.save

        assert @resource.errors.messages[:uid]
      end
    end

    describe 'email registration' do
      test 'model should not save if email is blank' do
        @resource = build(:user, email: nil)

        refute @resource.save
        assert @resource.errors.messages[:email] == [I18n.t('errors.messages.blank')]
      end

      test 'model should not save if email is not an email' do
        @resource = build(:user, email: '@example.com')

        refute @resource.save
        assert @resource.errors.messages[:email] == [I18n.t('errors.messages.not_email')]
      end
    end

    describe 'email uniqueness' do
      test 'model should not save if email is taken' do
        user_attributes = attributes_for(:user)
        create(:user, user_attributes)
        @resource = build(:user, user_attributes)

        refute @resource.save
        assert @resource.errors.messages[:email].first.include? 'taken'
        assert @resource.errors.messages[:email].none? { |e| e =~ /translation missing/ }
      end
    end

    describe 'oauth2 authentication' do
      test 'model should save even if email is blank' do
        @resource = build(:user, :facebook, email: nil)

        assert @resource.save
        assert @resource.errors.messages[:email].blank?
      end
    end

    describe 'token expiry' do
      before do
        @resource = create(:user, :confirmed)

        @auth_headers = @resource.create_new_auth_token

        @token     = @auth_headers['access-token']
        @client_id = @auth_headers['client']
      end

      test 'should properly indicate whether token is current' do
        assert @resource.token_is_current?(@token, @client_id)
        # we want to update the expiry without forcing a cleanup (see below)
        @resource.tokens[@client_id]['expiry'] = Time.zone.now.to_i - 10.seconds
        refute @resource.token_is_current?(@token, @client_id)
      end
    end

    describe 'token with extra data' do
      let(:extra_data) { { scope: "write:profile" } }
      before do
        @resource = create(:user, :confirmed)

        @auth_headers = @resource.create_new_auth_token(extra_data)

        @token     = @auth_headers['access-token']
        @client_id = @auth_headers['client']
      end

      test 'should extra data will be stored with token info' do
        assert @resource.token_is_current?(@token, @client_id)
        assert @resource.tokens[@client_id]["scope"], extra_data["scope"]
      end
    end

    describe 'previous token' do
      before do
        @resource = create(:user, :confirmed)

        @auth_headers1 = @resource.create_new_auth_token
      end

      test 'should properly indicate whether previous token is current' do
        assert @resource.token_is_current?(@auth_headers1['access-token'], @auth_headers1['client'])
        # create another token, emulating a new request
        @auth_headers2 = @resource.create_new_auth_token

        # should work for previous token
        assert @resource.token_is_current?(@auth_headers1['access-token'], @auth_headers1['client'])
        # should work for latest token as well
        assert @resource.token_is_current?(@auth_headers2['access-token'], @auth_headers2['client'])

        # after using latest token, previous token should not work
        assert @resource.token_is_current?(@auth_headers1['access-token'], @auth_headers1['client'])
      end
    end

    describe 'expired tokens are destroyed on save' do
      before do
        @resource = create(:user, :confirmed)

        @old_auth_headers = @resource.create_new_auth_token
        @new_auth_headers = @resource.create_new_auth_token
        expire_token(@resource, @old_auth_headers['client'])
      end

      test 'expired token was removed' do
        refute @resource.tokens[@old_auth_headers[:client]]
      end

      test 'current token was not removed' do
        assert @resource.tokens[@new_auth_headers['client']]
      end
    end

    describe 'nil tokens are handled properly' do
      before do
        @resource = create(:user, :confirmed)
      end

      test 'tokens can be set to nil' do
        @resource.tokens = nil
        assert @resource.save
      end
    end
  end

  describe 'clean_old_tokens' do
    before do
      @resource = create(:user, :confirmed)
      @token_lifespan = DeviseTokenAuth.token_lifespan
      @max_client_count = DeviseTokenAuth.max_number_of_devices
      DeviseTokenAuth.max_number_of_devices = 2
      DeviseTokenAuth.token_lifespan = 1.week
    end

    after do
      DeviseTokenAuth.token_lifespan = @token_lifespan
      DeviseTokenAuth.max_number_of_devices = @max_client_count
    end

    test 'removes tokens with expiry beyond the maximum lifespan' do
      # Create tokens with different expiry times
      current_time = Time.now.to_i

      max_lifespan = current_time + DeviseTokenAuth.token_lifespan.to_i

      # Valid token within lifespan
      @resource.tokens['valid_client'] = {
        'token' => 'valid_token',
        'expiry' => current_time + 1.day.to_i
      }

      # Token exactly at max lifespan (should be kept)
      @resource.tokens['edge_client'] = {
        'token' => 'edge_token',
        'expiry' => max_lifespan
      }

      # Token beyond max lifespan (should be removed)
      @resource.tokens['expired_client'] = {
        'token' => 'expired_token',
        'expiry' => max_lifespan + 1.day.to_i
      }

      # Call the method under test
      @resource.send(:clean_old_tokens)

      # Assert that tokens beyond lifespan were removed
      assert @resource.tokens.key?('valid_client'), 'Valid token should be kept'
      assert @resource.tokens.key?('edge_client'), 'Edge case token at max lifespan should be kept'
      refute @resource.tokens.key?('expired_client'), 'Token beyond max lifespan should be removed'
    end

    test 'handles token lifespan reduction when creating token' do
      # Setup: Create the maximum allowed number of tokens with a longer lifespan
      DeviseTokenAuth.token_lifespan = 2.weeks
      DeviseTokenAuth.max_number_of_devices = 3

      # Create tokens at different times but all within the initial long lifespan
      @resource.tokens = {}
      @resource.tokens['client_1'] = {
        'token' => 'token_1',
        'expiry' => Time.now.to_i + 12.days.to_i
      }

      @resource.tokens['client_2'] = {
        'token' => 'token_2',
        'expiry' => Time.now.to_i + 10.days.to_i
      }

      @resource.tokens['client_3'] = {
        'token' => 'token_3',
        'expiry' => Time.now.to_i + 5.days.to_i
      }

      # We've reached the maximum number of devices/tokens
      assert_equal 3, @resource.tokens.length

      # Now reduce token lifespan - simulating a config change
      DeviseTokenAuth.token_lifespan = 1.week

      # Create a new token which should trigger clean_old_tokens
      new_auth_headers = @resource.create_new_auth_token
      new_client = new_auth_headers['client']

      # The new token should exist
      assert @resource.tokens.key?(new_client), 'New token should exist'

      # Tokens exceeding the new reduced lifespan should be removed
      refute @resource.tokens.key?('client_1'), 'Token with expiry > new lifespan should be removed'
      refute @resource.tokens.key?('client_2'), 'Token with expiry > new lifespan should be removed'

      # Token within new lifespan should be kept
      assert @resource.tokens.key?('client_3'), 'Token within new reduced lifespan should be kept'

      # We should have exactly 2 tokens: the new one and client_3
      assert_equal 2, @resource.tokens.length
    end
  end
end
