release: bundle exec bin/rails db:migrate
web: bundle exec puma -C config/puma.rb -e ${RACK_ENV:-development}
worker: bundle exec sidekiq -C config/sidekiq.yml -e ${RACK_ENV:-development}