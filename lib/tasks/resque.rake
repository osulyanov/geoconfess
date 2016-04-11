require 'resque/tasks'
require 'resque/scheduler/tasks'

task 'resque:setup' => :environment
task 'resque:scheduler_setup' => :environment

desc 'Alias for resque:work (To run workers on Heroku)'
task 'jobs:work' => ['resque:work', 'resque:scheduler']
