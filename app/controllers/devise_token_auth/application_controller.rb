module DeviseTokenAuth
  class ApplicationController < DeviseController
    include DeviseTokenAuth::Concerns::SetUserByToken
    protect_from_forgery with: :null_session

    def resource_class(m=nil)
      if m
        mapping = Devise.mappings[m]
      else
        mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
      end

      mapping.to
    end
  end
end
