# Change these
server '3.110.101.151', port: 22, roles: %i[web app db], primary: true

set :repo_url,        'git@github.com:nirmal-vaja/UniversityMain.git'
set :application,     'UniversityMain'
set :branch,          'master'

set :rbenv_ruby,      '3.2.0'
# set :rbenv_ruby_dir,  '/home/ubuntu/.rbenv/versions/3.0.2'
set :default_env, { path: '~/.rbenv/shims:~/.rbenv/bin:$PATH' }

# If using Digital Ocean's Ruby on Rails Marketplace framework, your username is 'rails'
set :user,            'ubuntu'
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
# set :puma_user, fetch(:user)
# set :puma_enabled_socket_service, true
# set :puma_service_unit_env_files, []
# set :puma_service_unit_env_vars, []
# set :puma_role, :web
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w[~/.ssh/id_rsa.pub] }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true # Change to false when not using ActiveRecord
set :region, 'ap-south-1'

append :rbenv_map_bins, 'puma', 'pumactl'

## Defaults:
# set :scm,           :git
# set :branch,        :main
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before 'deploy:starting', 'puma:make_dirs'
end

namespace :deploy do # rubocop:disable Metrics/BlockLength
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      # Update this to your branch name: master, main, etc. Here it's main
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts 'WARNING: HEAD is not the same as origin/master'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Copy production.rb to the server'
  task :copy_production_rb do
    on roles(:app) do
      upload!('config/environments/production.rb', "#{release_path}/config/environments/production.rb")
    end
  end

  before 'deploy:publishing', 'copy_production_rb'

  # before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  # after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
