source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.7'

# Upgraded to Rails 7.0
gem 'rails', '~> 7.0.8'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use Puma as the app server
gem 'puma', '~> 5.0'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Hotwire stack: No more Webpacker/Node/Yarn!
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'

# Use Redis adapter for Action Cable real-time features
gem 'redis', '~> 4.0'

# Use HAML for views
gem 'haml-rails'

# Build JSON APIs with ease
gem 'jbuilder', '~> 2.7'

# Fixes the Logger name error in Ruby 3.0+ with Rails < 7.1
gem 'concurrent-ruby', '1.3.4'

# Reduces boot times through caching
gem 'bootsnap', require: false

gem 'ruby-openai'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages
  gem 'web-console'
  # Display performance information
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Generate fake data for seeds
  gem 'faker'
end

group :test do
  # Adds support for Capybara system testing
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
end

# Windows compatibility
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]