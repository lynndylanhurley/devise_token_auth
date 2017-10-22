require 'test_helper'

class MultiAuthUserTest < ActiveSupport::TestCase
  describe MultiAuthUser do
    describe '.find_resource' do
      before do
        @resource = multi_auth_users(:multi_authed_user)
        @resource.save!
      end

      test 'finding the resource with simple custom finder methods for a provider' do
        found_resource = MultiAuthUser.find_resource(@resource.twitter_id, 'twitter')
        assert_equal @resource, found_resource
      end

      test 'finding the resource with complex custom finder methods for a provider' do
        facebook_user = FacebookUser.create!(facebook_id: 98765)
        @resource.update_attributes!(facebook_user: facebook_user)

        found_resource = MultiAuthUser.find_resource(facebook_user.facebook_id, 'facebook')
        assert_equal @resource, found_resource
      end

      test 'finding the resource successfully with no provider' do
        # Searches just by default authorize key, which in this case is email
        found_resource = MultiAuthUser.find_resource(@resource.email, nil)
        assert_equal @resource, found_resource
      end

      test 'finding the resource successfully with no custom finder method for email' do
        found_resource = MultiAuthUser.find_resource(@resource.email, 'email')
        assert_equal @resource, found_resource
      end

      test 'finding the resource successfully with a non-email, non-oauth provider' do
        found_resource = MultiAuthUser.find_resource(@resource.nickname, 'nickname')
        assert_equal @resource, found_resource
      end
    end

    describe 'email uniqueness' do
      before do
        email = Faker::Internet.email
        @resource = MultiAuthUser.create!(
          email:                 email,
          password:              'somepassword',
          password_confirmation: 'somepassword',
          uid: email
        )

        @new_resource = MultiAuthUser.new(
          email:                 @resource.email,
          password:              'anotherpassword',
          password_confirmation: 'anotherpassword',
          uid: email
        )
      end

      # This is to avoid being opinionated about domain objects; who are we to
      # say that emails should be unique or not? The reason for this test is
      # that when provider/uid columns are in use, we are opinionated and *do*
      # care.
      test 'not validating uniqueness by default' do
        assert(@new_resource.save)
      end
    end
  end
end
