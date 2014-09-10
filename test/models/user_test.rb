require 'test_helper'

class UserTest < ActiveSupport::TestCase
  describe User do
    before do
      @password    = Faker::Internet.password(10, 20)
      @email       = Faker::Internet.email
      @success_url = Faker::Internet.url
      @user        = User.new()
    end

    describe 'serialization' do
      test 'hash should not include sensitive info' do
        refute @user.as_json[:tokens]
      end
    end

    describe 'email registration' do
      test 'model should not save if email is blank' do
        @user.provider              = 'email'
        @user.password              = @password
        @user.password_confirmation = @password
        @user.confirm_success_url   = @success_url

        refute @user.save
        assert @user.errors.messages[:email]
      end

      test 'model should not save if confirm_success_url is not provided' do
        @user.provider              = 'email'
        @user.email                 = @email
        @user.password              = @password
        @user.password_confirmation = @password

        refute @user.save
        assert @user.errors.messages[:confirm_success_url]
      end
    end

    describe 'oauth2 authentication' do
      test 'model should save even if email is blank' do
        @user.provider              = 'facebook'
        @user.password              = @password
        @user.password_confirmation = @password
        @user.confirm_success_url   = @success_url

        assert @user.save
        refute @user.errors.messages[:email]
      end
    end
  end
end
