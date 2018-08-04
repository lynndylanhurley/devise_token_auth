# frozen_string_literal: true

[
  { name: '4-2', version: '4.2.10' }
].each do |rails|
  appraise "rails-#{rails[:name]}" do
    gem 'mysql2', '~> 0.4.10'
    gem 'pg', '~> 0.21'
    gem 'rails', "~> #{rails[:version]}"
  end
end

[
  { name: '5-0', version: '5.0.7' },
  { name: '5-1', version: '5.1.6' }
].each do |rails|
  appraise "rails-#{rails[:name]}" do
    gem 'rails', "~> #{rails[:version]}"
  end
end
