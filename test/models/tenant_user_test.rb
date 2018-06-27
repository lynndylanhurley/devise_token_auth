# frozen_string_literal: true

require 'test_helper'

class TenantUserTest < ActiveSupport::TestCase
  describe TenantUser do
    before do
      @password    = Faker::Internet.password(10, 20)
      @email       = Faker::Internet.email
      @success_url = Faker::Internet.url
      @resource    = TenantUser.new()
    end

    describe 'email uniqueness' do
      test 'model should not save if email is taken within the same tenant' do
        provider = 'email'

        TenantUser.create(
          email: @email,
          provider: provider,
          password: @password,
          password_confirmation: @password,
          tenant: 'tenant1'
        )

        @resource.email                 = @email
        @resource.provider              = provider
        @resource.password              = @password
        @resource.password_confirmation = @password
        @resource.tenant                = 'tenant1'

        refute @resource.save
        assert @resource.errors.messages[:email] == [I18n.t('errors.messages.taken')]
        assert @resource.errors.messages[:email].none? { |e| e =~ /translation missing/ }
      end

      test 'model should save if email is not taken within the same tenant' do
        provider = 'email'

        TenantUser.create(
          email: @email,
          provider: provider,
          password: @password,
          password_confirmation: @password,
          tenant: 'tenant1'
        )

        @resource.email                 = @email
        @resource.provider              = provider
        @resource.password              = @password
        @resource.password_confirmation = @password
        @resource.tenant                = 'tenant2'

        assert @resource.save
      end
    end
  end
end
