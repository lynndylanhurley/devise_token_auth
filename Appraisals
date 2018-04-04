[
  { name: '5-0', version: '5.0.7' },
  { name: '5-1', version: '5.1.6' },
].each do |rails|
  appraise "rails-#{rails[:name]}" do
    gem "rails", "~> #{rails[:version]}"
  end
end
