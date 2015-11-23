require 'test_helper'

class UserTest < ActiveSupport::TestCase
  describe User do
    before do
      @password    = Faker::Internet.password(10, 20)
      @email       = Faker::Internet.email
      @success_url = Faker::Internet.url
      @resource    = User.new()
    end

    describe 'serialization' do
      test 'hash should not include sensitive info' do
        refute @resource.as_json[:tokens]
      end
    end

    describe 'creation' do
      test 'save fails if uid is missing' do
        @resource.uid = nil
        @resource.save

        assert @resource.errors.messages[:uid]
      end
    end

    describe 'email registration' do
      test 'model should not save if email is blank' do
        @resource.provider              = 'email'
        @resource.password              = @password
        @resource.password_confirmation = @password

        refute @resource.save
        assert @resource.errors.messages[:email]
      end
    end

    describe 'oauth2 authentication' do
      test 'model should save even if email is blank' do
        @resource.provider              = 'facebook'
        @resource.uid                   = 123
        @resource.password              = @password
        @resource.password_confirmation = @password

        assert @resource.save
        refute @resource.errors.messages[:email]
      end
    end

    describe 'token expiry' do
      before do
        @resource = users(:confirmed_email_user)
        @resource.skip_confirmation!
        @resource.save!

        @auth_headers = @resource.create_new_auth_token

        @token     = @auth_headers['access-token']
        @client_id = @auth_headers['client']
      end

      test 'should properly indicate whether token is current' do
        assert @resource.token_is_current?(@token, @client_id)
        # we want to update the expiry without forcing a cleanup (see below)
        @resource.tokens[@client_id]['expiry'] = Time.now.to_i - 10.seconds
        refute @resource.token_is_current?(@token, @client_id)
      end
    end

    describe 'expired tokens are destroyed on save' do
      before do
        @resource = users(:confirmed_email_user)
        @resource.skip_confirmation!
        @resource.save!

        @old_auth_headers = @resource.create_new_auth_token
        @new_auth_headers = @resource.create_new_auth_token
        expire_token(@resource, @old_auth_headers['client'])
      end

      test 'expired token was removed' do
        refute @resource.tokens[@old_auth_headers[:client]]
      end

      test 'current token was not removed' do
        assert @resource.tokens[@new_auth_headers["client"]]
      end
    end

    describe 'nil tokens are handled properly' do
      before do
        @resource = users(:confirmed_email_user)
        @resource.skip_confirmation!
        @resource.save!
      end

      test 'tokens can be set to nil' do
        @resource.tokens = nil
        assert @resource.save
      end
    end

    describe '.find_resource' do
      before do
        @resource = users(:confirmed_email_user)
        @resource.skip_confirmation!
        @resource.save!
      end

      test 'finding the resource successfully with custom finder methods for a provider' do
        @resource.update_attributes!(twitter_id: 98765)
        found_resource = User.find_resource(@resource.twitter_id, 'twitter')

        assert_equal @resource, found_resource
      end

      test 'finding the resource successfully with no provider' do
        # Searches just by uid, which by default for this resource is email
        found_resource = User.find_resource(@resource.email, nil)
        assert_equal @resource, found_resource
      end

      test 'finding the resource successfully with no custom finder method for email' do
        found_resource = User.find_resource(@resource.email, 'email')
        assert_equal @resource, found_resource
      end

      test 'finding the resource successfully with no custom finder method for an oauth provider' do
        @resource.update_attributes!(provider: 'facebook', uid: '12234567')
        found_resource = User.find_resource(12234567, 'facebook')
        assert_equal @resource, found_resource
      end

      test 'finding the resource successfully with a non-email, non-oauth provider' do
        found_resource = User.find_resource(@resource.nickname, 'nickname')
        assert_equal @resource, found_resource
      end
    end

    describe 'email uniqueness' do
      before do
        email = Faker::Internet.email
        @resource = User.create!(
          email:                 email,
          uid:                   email,
          provider:              'email',
          password:              'somepassword',
          password_confirmation: 'somepassword'
        )
      end

      test 'creating user with existing email adds an error' do
        new_resource = User.new(
          email:                 @resource.email,
          uid:                   @resource.email,
          provider:              'email',
          password:              'anotherpassword',
          password_confirmation: 'anotherpassword'
        )

        refute(new_resource.save)
        assert_includes(new_resource.errors.keys, :email)
      end
    end
  end
end
