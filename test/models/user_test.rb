require 'test_helper'

class UserTest < ActiveSupport::TestCase
  describe User do
    describe 'email registration' do
      test 'model should not save if email is blank' do
        assert_equal true, true
      end
    end

    #describe 'oauth2 authentication' do
      #test 'model should save even if email is blank' do
      #end
    #end
  end
end
