# Capistrano Recipes for managing delayed_job
#
# Add these callbacks to have the delayed_job process restart when the server
# is restarted:
#
#   after "deploy:stop",    "delayed_job:stop"
#   after "deploy:start",   "delayed_job:start"
#   after "deploy:restart", "delayed_job:restart"
#
# If you want to use command line options, for example to start multiple workers,
# define a Capistrano variable delayed_job_args:
#
#   set :delayed_job_args, "-n 2"
#
# If you've got delayed_job workers running on a servers, you can also specify
# which servers have delayed_job running and should be restarted after deploy.
#
#   set :delayed_job_server_role, :worker
#

Capistrano::Configuration.instance.load do
  namespace :delayed_job do
    def rails_env
      fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
    end

    def args
      fetch(:delayed_job_args, "")
    end

    def roles
      fetch(:delayed_job_server_role, :app)
    end

    desc "Stop the delayed_job process"
    task :stop, :roles => lambda { roles } do
      #CHRISDO: How do we stop the www-data daemons started with sudo below??
      run "cd #{current_path};sudo -E #{rails_env} script/delayed_job stop"
    end

    desc "Start the delayed_job process"
    task :start, :roles => lambda { roles } do
      #POSSIBLE BUG: If the command.rb file is edited to not specify the default user then the daemons will
      #be running as root
      run "cd #{current_path};sudo -E #{rails_env} script/delayed_job start -u www-data #{args}"
    end

    desc "Restart the delayed_job process"
    task :restart, :roles => lambda { roles } do
      run "cd #{current_path};sudo -E #{rails_env} script/delayed_job restart -u www-data #{args}"
    end
  end
end
