require 'test_helper'

# Assertions to test routes
# http://api.rubyonrails.org/v4.2.10/classes/ActionDispatch/Assertions/RoutingAssertions.html

class RoutesTest < ActionDispatch::IntegrationTest
  describe 'RoutesTest' do
    teardown do
      Rails.application.reload_routes!
    end

    describe 'mapping with scope' do
      setup do
        Rails.application.routes.draw do

          scope '/api/v1', defaults: {format: :json} do
            mount_devise_token_auth_for 'User', at: 'auth'
          end

        end

        @scope          = '/api/v1'
        @defaults       = {format: :json}
        @resource_class = 'User'
        @at             = 'auth'
      end

      describe 'validate_token route' do
        test 'should accepts defaults' do
          # all validate_token attributes available here
           # @routes.routes.anchored_routes[18]

          options  = { controller: 'devise_token_auth/token_validations', action: 'validate_token' }
          prefix   = "#{@scope}/#{@at}"

          assert_routing(prefix + '/validate_token', @defaults.merge(options))
        end
      end
    end

    describe 'mapping with namespace' do
      setup do
        Rails.application.routes.draw do

          namespace :api do
            namespace :v1, defaults: {format: :json}  do
              mount_devise_token_auth_for 'User', at: 'auth'
            end
          end

        end

        @scope          = '/' + [:api, :v1].join('/')
        @defaults       = {format: :json}
        @resource_class = 'User'
        @at             = 'auth'
      end

      describe 'validate_token route' do
        test 'should accepts defaults' do
          options  = { controller: 'devise_token_auth/token_validations', action: 'validate_token' }
          prefix   = "#{@scope}/#{@at}"

          assert_routing(prefix + '/validate_token', @defaults.merge(options))
        end
      end
    end
  end
end
