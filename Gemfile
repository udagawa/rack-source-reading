source 'https://rubygems.org'

gem 'webrick'

group :test do
  gem 'pry'
  gem 'rake'
  gem "minitest"
  gem "minitest-power_assert"
  gem "minitest-reporters"
end

group :development do
  gem 'guard', "2.11.1"
  gem "guard-minitest"
  gem 'wdm', '>= 0.1.0' if Gem.win_platform?
end

