# frozen_string_literal: true

[
  { name: '4-2', version: '4.2.10' }
].each do |rails|
  appraise "rails-#{rails[:name]}" do
    gem 'rails', "~> #{rails[:version]}"

    gem 'sqlite3', '~> 1.3'
    gem 'mysql2', '~> 0.4.10'
    gem 'pg', '~> 0.21'
  end
end

[
  { name: '5-0', version: '5.0.7' },
  { name: '5-1', version: '5.1.6' },
  { name: '5-2', version: '5.2.1' }
].each do |rails|
  appraise "rails-#{rails[:name]}" do
    gem 'rails', "~> #{rails[:version]}"

    gem 'sqlite3'
    gem 'mysql2'
    gem 'pg'
  end
end

[
  { name: '4-2', ruby: '2.2.10', rails: '4.2.10', mongoid: '5.4.0' },
  { name: '5-1', ruby: '2.3.7', rails: '5.1.6', mongoid: '6.4.1' },
  { name: '5-1', ruby: '2.4.4', rails: '5.1.6', mongoid: '7.0.1' },
  { name: '5-2', ruby: '2.5.1', rails: '5.2.1', mongoid: '6.4.1' },
  { name: '5-2', ruby: '2.5.1', rails: '5.2.1', mongoid: '7.0.2' }
].each do |set|
  appraise "rails-#{set[:name]}-mongoid-#{set[:mongoid][0]}" do
    gem 'rails', set[:rails]

    gem 'mongoid', set[:mongoid]
    gem 'mongoid-locker', '~> 1'
  end
end

# TODO: remove this appraise when the issue be fixed in rails 5.2.x release.
# https://github.com/rails/rails/commit/47a6d788ddbab08b2a04c72cd80352aac44090ab
appraise 'rails-5-2-stable-mongoid-6' do
  gem 'rails', git: 'https://github.com/rails/rails.git', branch: '5-2-stable'

  gem 'mongoid', '6.4.1'
  gem 'mongoid-locker', '~> 1'
end
