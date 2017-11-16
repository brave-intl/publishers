release: bundle exec bin/rails db:migrate -e ${RACK_ENV:-development}
web: bundle exec puma -C config/puma.rb -e ${RACK_ENV:-development}
worker: bundle exec sidekiq -C config/sidekiq.yml -e ${RACK_ENV:-development}