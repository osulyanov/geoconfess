if ENV['REDISTOGO_URL']
  uri = URI.parse(ENV['REDISTOGO_URL'])
  Resque.redis = Redis.new(host: uri.host, port: uri.port,
                           password: uri.password, thread_safe: true)
end
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
