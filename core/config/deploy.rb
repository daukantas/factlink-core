#############
# Application
set :application, "factlink-core"
set :keep_releases, 10

########
# Stages
set :stages, %w(testserver staging production)
require 'capistrano/ext/multistage'

#################
# Bundler support
require "bundler/capistrano"

#############
# RVM support
# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# Load RVM's capistrano plugin.
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2'
set :rvm_bin_path, "/usr/local/rvm/bin"

set :user, "deploy"
set :use_sudo,    false

# Repository
set :scm, :git
set :repository,  "git@github.com:Factlink/core.git"

set :deploy_to, "/applications/#{application}"
set :deploy_via, :remote_cache    # only fetch changes since since last

ssh_options[:forward_agent] = true


# If you are using Passenger mod_rails uncomment this:
namespace :deploy do

  task :all do
    set_conf_path="export CONFIG_PATH=#{deploy_to}/current; export NODE_ENV=#{deploy_env};"
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :check_installed_packages do
    run "sh #{current_release}/bin/server/check_installed_packages.sh"
  end

  task :start_recalculate do
    run "sh #{current_path}/bin/server/start_recalculate.sh #{deploy_env}"
  end
  task :stop_recalculate do
    run "sh #{current_path}/bin/server/stop_recalculate.sh"
  end

  task :start_resque do
    run "sh #{current_path}/bin/server/start_resque_using_monit.sh"
  end
  task :stop_resque do
    run "sudo /usr/sbin/monit stop resque"
  end

  task :reindex do
    run "cd #{current_path}; bundle exec rake sunspot:solr:reindex RAILS_ENV=#{deploy_env}"
  end

  task :curl_site do
    run <<-CMD
      curl --user deploy:sdU35-YGGdv1tv21jnen3 #{full_url}
    CMD
  end
end

before 'deploy:all',      'deploy'
after 'deploy:all',       'deploy:restart'
after 'deploy:all',       'deploy:reindex'

before 'deploy:migrate',  'deploy:stop_recalculate'
before 'deploy:migrate',  'deploy:stop_resque'

after 'deploy',           'deploy:migrate'

after 'deploy:migrate',   'deploy:start_recalculate'
after 'deploy:migrate',   'deploy:start_resque'

after 'deploy:update', 'deploy:check_installed_packages'
after 'deploy:check_installed_packages', 'deploy:cleanup'

after 'deploy', 'deploy:curl_site'