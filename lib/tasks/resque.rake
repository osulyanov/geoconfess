require 'resque/tasks'
require 'resque/scheduler/tasks'

module ResqueWorker
  extend self

  def scheduler_or_worker?
    ENV['SCHEDULER_REDIRECT'] ? 'scheduler' : 'work'
  end
end

task 'resque:setup' => :environment
task 'resque:scheduler_setup' => :environment

desc 'Alias for resque:work (To run workers on Heroku)'
task 'jobs:work' => ['resque:work', 'resque:scheduler'] do
  ENV['QUEUE'] = '*'
  Rake::Task["resque:#{ResqueWorker.scheduler_or_worker?}"].invoke
end
