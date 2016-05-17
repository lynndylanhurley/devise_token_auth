class Company < ActiveRecord::Base
  has_one :account, as: :owner
end
