FactoryGirl.define do
  timestamp = DateTime.parse(2.weeks.ago.to_s).to_time.strftime("%F %T")

  factory :mongoid_scoped_user, class: MongoidScopedUser do |u|
    sequence(:email) { |n| "user#{n}@example.com" }
    provider 'email'
    uid { email }
    confirmed_at  { timestamp }
    created_at { timestamp }
    updated_at { timestamp }
    password 'secret123'
    encrypted_password { MongoidScopedUser.new.send(:password_digest, 'secret123') }
    trait :facebook do
      provider 'facebook'
      uid { Faker::Number.number(10) }
    end
  end
end
