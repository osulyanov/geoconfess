require 'resque/tasks'
require 'resque/scheduler/tasks'

task 'resque:setup' => :environment do
  ENV['QUEUE'] = '*'
  ENV['TERM_CHILD'] = 1
  ENV['RESQUE_TERM_TIMEOUT'] = 7
end

task 'resque:scheduler_setup' => :environment

desc 'Alias for resque:work (To run workers on Heroku)'
task 'jobs:work' => ['resque:work', 'resque:scheduler']
