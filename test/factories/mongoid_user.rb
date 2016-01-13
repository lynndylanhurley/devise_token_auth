timestamp = DateTime.parse(2.weeks.ago.to_s).to_time.strftime("%F %T")
FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :mongoid_user, class: MongoidUser do
    name 'John Doe'
    email
    provider 'email'
    confirmed_at  { timestamp }
    created_at { timestamp }
    updated_at { timestamp }
    password 'secret123'
    encrypted_password { User.new.send(:password_digest, 'secret123') }
  end
end
