# frozen_string_literal: true

require 'test_helper'

class DeviseTokenAuth::CustomRoutesTest < ActiveSupport::TestCase
  after do
    Rails.application.reload_routes!
  end
  test 'custom controllers' do
    Rails.application.routes.draw do
      mapper = self
      mapper.singleton_class.include(Mocha::API)
      mapper.singleton_class.include(Mocha::ParameterMatchers)

      mapper.expects(:devise_for).with(
        :users,
        has_entries(
          controllers: has_entries(
            invitations: "custom/invitations", foo: "custom/foo"
          )
        )
      )

      mount_devise_token_auth_for 'User', at: 'my_custom_users', controllers: {
        invitations: 'custom/invitations',
        foo: 'custom/foo'
      }
    end
  end
end
