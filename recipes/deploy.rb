# Adapted from deploy::rails: https://github.com/aws/opsworks-cookbooks/blob/master/deploy/recipes/rails.rb

include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping opsworks_sidekiq::deploy application #{application} as it is not an Rails app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  node.set[:opsworks][:rails_stack][:recipe] = "opsworks_sidekiq::setup"

  opsworks_rails do
    deploy_data deploy
    app application
  end

  node.set[:opsworks][:rails_stack][:restart_command] = node[:sidekiq][application][:restart_command]

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end
