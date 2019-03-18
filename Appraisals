# frozen_string_literal: true

[
  { name: '4-2', version: '4.2' }
].each do |rails|
  appraise "rails-#{rails[:name]}" do
    gem 'rails', "~> #{rails[:version]}"

    gem 'sqlite3', '~> 1.3.6'
    gem 'mysql2', '~> 0.4.10'
    gem 'pg', '~> 0.21'
  end
end

[
  { name: '5-0', version: '5.0' },
  { name: '5-1', version: '5.1' },
  { name: '5-2', version: '5.2' }
].each do |rails|
  appraise "rails-#{rails[:name]}" do
    gem 'rails', "~> #{rails[:version]}"

    gem 'sqlite3', '~> 1.3.6'
    gem 'mysql2'
    gem 'pg'
  end
end

[
  { name: '4-2', ruby: '2.3.8', rails: '4.2', mongoid: '5.4' },
  { name: '5-1', ruby: '2.3.8', rails: '5.1', mongoid: '6.4' },
  { name: '5-1', ruby: '2.4.5', rails: '5.1', mongoid: '7.0' },
  { name: '5-2', ruby: '2.5.5', rails: '5.2', mongoid: '6.4' },
  { name: '5-2', ruby: '2.5.5', rails: '5.2', mongoid: '7.0' },
  { name: '5-2', ruby: '2.6.2', rails: '5.2', mongoid: '7.0' }
].each do |set|
  appraise "rails-#{set[:name]}-mongoid-#{set[:mongoid][0]}" do
    gem 'rails', "~> #{set[:rails]}"

    gem 'mongoid', "~> #{set[:mongoid]}"
    gem 'mongoid-locker', '~> 1.0'
  end
end
