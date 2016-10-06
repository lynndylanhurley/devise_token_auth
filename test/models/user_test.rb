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

    describe 'email uniqueness' do
      test 'model should not save if email is taken' do
        provider = 'email'

        User.create(
          email: @email,
          provider: provider,
          password: @password,
          password_confirmation: @password
        )

        @resource.email                 = @email
        @resource.provider              = provider
        @resource.password              = @password
        @resource.password_confirmation = @password

        refute @resource.save
        assert @resource.errors.messages[:email] == [I18n.t('errors.messages.taken')]
        assert @resource.errors.messages[:email].none? { |e| e =~ /translation missing/ }
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
  end
end
