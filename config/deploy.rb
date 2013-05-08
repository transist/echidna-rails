require 'capistrano_colors'

set :application, 'echidna'
set :repository, 'git@github.com:transist/echidna-rails.git'
set :scm, :git
set :deploy_via, :remote_cache
set :use_sudo, false
set :user, 'echidna'

set :rvm_ruby_string, :local
require 'rvm/capistrano'

set :bundle_flags, '--deployment --quiet --binstubs'
set :bundle_without, [:development, :test]
require 'bundler/capistrano'

# Use HTTP proxy from Transist server to help bundler cross the GFW
set :default_environment, {
  http_proxy: 'http://192.168.1.42:8123'
}

# Make capistrano create shared/sockets and symlink it to tmp/sockets
set :shared_children, shared_children + %w(tmp/sockets)

role :app, 'echidna.transi.st'
role :web, 'echidna.transi.st'
role :db,  'echidna.transi.st', primary: true
set :port, 2220
set :branch, 'master'
set :rails_env, 'production'
set :deploy_to, '/home/echidna/echidna.transi.st'

after 'deploy:restart', 'deploy:cleanup'

namespace :deploy do
  desc 'Restart unicorn'
  task :restart do
    run <<-BASH
      kill -USR2 `cat /home/echidna/echidna.transi.st/shared/pids/unicorn.pid`
    BASH
  end

  desc 'Start unicorn'
  task :start, roles: :app do
    run <<-BASH
      cd #{current_release} &&
      bin/unicorn_rails -c #{current_release}/config/unicorn.rb -D -E #{rails_env}
    BASH
  end

  desc 'Stop unicorn'
  task :stop, roles: :app do
    run <<-BASH
      kill -QUIT `cat /home/echidna/echidna.transi.st/shared/pids/unicorn.pid`
    BASH
  end
end
