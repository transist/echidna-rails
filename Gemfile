source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'jquery-rails'
gem 'mongoid', '>= 3.1.2'
gem 'slim', '>= 2.0.0.pre.6'
gem 'devise', '>= 2.2.3'
gem 'figaro', '>= 0.6.3'
gem 'inherited_resources'
gem 'simple_form'
gem 'faraday'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'guard-bundler', '>= 1.0.0'
  gem 'guard-cucumber', '>= 1.4.0'
  gem 'guard-rails', '>= 0.4.0'
  gem 'guard-rspec', '>= 2.5.2'
  gem 'rb-inotify', '>= 0.9.0', require: false
  gem 'rb-fsevent', '>= 0.9.3', require: false
  gem 'rb-fchange', '>= 0.0.6', require: false
  gem 'quiet_assets', '>= 1.0.2'
  gem 'better_errors', '>= 0.7.2'
  gem 'binding_of_caller', '>= 0.7.1'
end

group :test do
  gem 'database_cleaner', '>= 1.0.0.RC1'
  gem 'mongoid-rspec', '>= 1.7.0'
  gem 'email_spec', '>= 1.4.0'
  gem 'cucumber-rails', '>= 1.3.1', require: false
  gem 'launchy', '>= 2.2.0'
  gem 'capybara', '>= 2.0.3'
end

group :development, :test do
  gem 'rspec-rails', '>= 2.12.2'
  gem 'factory_girl_rails', '>= 4.2.0'
end

group :production do
  gem 'unicorn', '>= 4.3.1'
end
