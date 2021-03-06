require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'active_scheduler'

namespace :resque do
  task setup: :environment do
    require 'resque'
  end

  task setup_schedule: :environment do
    require 'resque-scheduler'
    file_name = "#{Rails.root}/config/resque_schedule.yml"
    yaml_schedule = YAML.load_file(file_name) || {}
    wrapped_schedule = ActiveScheduler::ResqueWrapper.wrap yaml_schedule
    Resque.schedule = wrapped_schedule
  end

  task scheduler: :setup_schedule
end
