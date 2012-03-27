# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :stages, %w(staging production testing)
require 'capistrano/ext/multistage'

#set :application, "manuscripts"
set :repository, "svn://panther.sageserver.com/svn_home/manuscripts/trunk"

set :use_sudo, true


# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

#role :web, "lilo.duhs.duke.edu"
#role :app, "lilo.duhs.duke.edu"
#role :db,  "lilo.duhs.duke.edu", :primary => true

set :mongrel_port, "4000"

default_run_options[:pty] = true
set :primary_server, "64.15.147.55"
   
 #"pdg@#{primary_server}"
role :web, primary_server
role :app, primary_server
role :db,  primary_server, :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
# set :deploy_to, "/path/to/app" # defaults to "/u/apps/#{application}"
# set :user, "flippy"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway
# 


default_run_options[:pty] = true
set :scm_prefer_prompt,true

#set :deploy_to, "/dev_apps/#{application}" # defaults to "/u/apps/#{application}"
set :user, "deploy"  # defaults to pdg
set :password,"RofqQe5UXf"
set :scm_user,"brian"
set :scm_password,"lemon34"
set :scm, :subversion            # set to subversion for us
set :svn, "/usr/bin/svn"         # svn 

desc "DeployMongrel"
task :deploy_app, :roles => :app do   
   p "^^^^^^^^^^^#{rails_env}"
   deploy.update
   p "update successful"
   create_syms
   p "syms successfful"
   deploy.migrate
   p "migration succesful"
#   unless  rails_env == "productssion"
#   run "cd #{current_path} && mongrel_rails stop"
#   run "cd #{current_path} && mongrel_rails start -p #{mongrel_port} -e development -d"
#   end
end

desc "Setup Symlinks"
task :create_syms,:roles=>:app do
    public = %w(4fce4853c798a47a5c2c598aa546fa07dkd3 faq cover_letter additional_file manuscript manuscripts permission updated_manuscript)
    public.each do  |dir|
       run "sudo ln -nfs #{deploy_to}/shared/#{dir} #{current_path}/public/#{dir}"
       p "**********************#{dir}***************************************************"
    end

end


desc "Remove Symlinks"
task :remove_symlinks,:roles=>:app do
    public = %w(4fce4853c798a47a5c2c598aa546fa07dkd3 faq cover_letter additional_file manuscript manuscripts permission updated_manuscript)
    public.each do  |dir|
       run "sudo rm -f #{current_path}/public/#{dir}"
       p "**********************#{dir}***************************************************"
    end

end


