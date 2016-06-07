postgresql:       postgres -D /usr/local/var/postgres
server:           bundle exec rails s
redis:            redis-server /usr/local/etc/redis.conf
resque:           bundle exec rake resque:work QUEUE=* TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7
scheduler:        bundle exec rake resque:scheduler
# release:          bundle exec rake db:migrate
