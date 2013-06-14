require 'capistrano_colors'

set :application, 'echidna'
set :repository, 'git@github.com:transist/echidna-rails.git'
set :scm, :git
set :deploy_via, :remote_cache
set :use_sudo, false
set :user, 'echidna'

set :rvm_ruby_string, :local
require 'rvm/capistrano'

# Use HTTP proxy from Transist server to help bundler cross the GFW
set :bundle_cmd, 'http_proxy=http://192.168.1.42:8123 bundle'
set :bundle_flags, '--deployment --quiet --binstubs'
set :bundle_without, [:development, :test]
require 'bundler/capistrano'

require 'sidekiq/capistrano'
set :sidekiq_role, :sidekiq
set :sidekiq_processes, 2
role :sidekiq, 'echidna.transi.st'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

# Make capistrano create shared/sockets and symlink it to tmp/sockets
set :shared_children, shared_children + %w(tmp/sockets)

role :app, 'echidna.transi.st'
role :web, 'echidna.transi.st'
role :db,  'echidna.transi.st', primary: true
set :port, 2220
set :branch, 'develop'
set :rails_env, 'production'
set :deploy_to, '/home/echidna/echidna.transi.st'

after 'deploy:update_code', 'deploy:symbolic_links'
after 'deploy:restart', 'deploy:cleanup'
after 'deploy:restart', 'unicorn:restart'
after 'deploy:restart', 'spider:restart'
after 'deploy:start', 'unicorn:start'
after 'deploy:start', 'spider:start'
after 'deploy:stop', 'unicorn:stop'
after 'deploy:stop', 'spider:stop'

namespace :unicorn do
  desc 'Restart unicorn'
  task :restart do
    run <<-BASH
      kill -USR2 `cat #{shared_path}/pids/unicorn.pid`
    BASH
  end

  desc 'Start unicorn'
  task :start, roles: :app do
    run <<-BASH
      cd #{current_release} &&
      bin/unicorn_rails -c config/unicorn.rb -D -E #{rails_env}
    BASH
  end

  desc 'Stop unicorn'
  task :stop, roles: :app do
    run <<-BASH
      kill -QUIT `cat #{shared_path}/pids/unicorn.pid`
    BASH
  end
end

namespace :spider do
  desc 'Start spider'
  task :start, roles: :app do
    run "cd #{current_release}; nohup bin/rake RAILS_ENV=production spider_scheduler > /dev/null 2>&1 &"
  end

  desc 'Stop spider'
  task :stop, roles: :app do
    run "kill `cat #{shared_path}/pids/spider_scheduler.pid`"
  end

  desc 'Restart spider'
  task :restart, roles: :app do
    stop
    start
  end
end

namespace :deploy do
  desc 'Symbolic links'
  task :symbolic_links do
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/cache #{release_path}/cache"
  end


  desc 'Create index'
  task :create_indexes, roles: :db do
    run "cd #{current_release}; rake db:mongoid:create_indexes"
  end
end
