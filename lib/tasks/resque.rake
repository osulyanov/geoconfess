require 'resque/tasks'
task "resque:setup" => :environment
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
