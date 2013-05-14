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
gem 'fazscore', github: 'transist/fazscore'

gem 'sidekiq'
gem 'sidekiq_status'
gem 'kiqstand'
gem 'sinatra', '>= 1.3.0', require: nil

gem 'oauth2', git: 'git://github.com/rainux/oauth2'
gem 'tencent-weibo', git: 'git://github.com/rainux/tencent-weibo'
gem 'rufus-scheduler', git: 'git://github.com/rainux/rufus-scheduler'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'thin'
  gem 'guard-bundler', '>= 1.0.0'
  gem 'guard-cucumber', '>= 1.4.0'
  gem 'guard-rails', '>= 0.4.0'
  gem 'guard-rspec', '>= 2.5.2'
  gem 'guard-sidekiq'
  gem 'guard-zeus'
  gem 'rb-inotify', '>= 0.9.0', require: false
  gem 'rb-fsevent', '>= 0.9.3', require: false
  gem 'rb-fchange', '>= 0.0.6', require: false
  gem 'quiet_assets', '>= 1.0.2'
  gem 'better_errors', '>= 0.7.2'
  gem 'binding_of_caller', '>= 0.7.1'
  gem 'capistrano', require: nil
  gem 'capistrano_colors', require: nil
  gem 'rvm-capistrano', require: nil
  gem 'zeus', require: nil
end

group :test do
  gem 'database_cleaner', '>= 1.0.0.RC1'
  gem 'mongoid-rspec', '>= 1.7.0'
  gem 'email_spec', '>= 1.4.0'
  gem 'cucumber-rails', '>= 1.3.1', require: false
  gem 'launchy', '>= 2.2.0'
  gem 'capybara', '>= 2.0.3'
  gem 'timecop'
  gem 'mocha', require: 'mocha/api'
end

group :development, :test do
  gem 'awesome_print'
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-nav'
  gem 'rspec-rails', '>= 2.12.2'
  gem 'factory_girl_rails', '>= 4.2.0'
end

group :production do
  gem 'unicorn', '>= 4.3.1'
end
