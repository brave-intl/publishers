App for [publishers.brave.com](https://publishers.brave.com).

[![Build Status](https://travis-ci.org/brave/publishers.svg?branch=master)](https://travis-ci.org/brave/publishers)

## Development

### Initial setup

1. Ruby 2.3.3. For a Ruby version manager try [rbenv](https://github.com/rbenv/rbenv).
2. Postgresql 9.5+: `brew install postgresql` (start with `brew services start postgresql`)
3. Redis: `brew install redis`
4. Install ruby gems: `gem install bundler foreman`
5. Install project dependencies: `bundle install --jobs=$(nproc)`
  - Possible error: Nokogiri, with libxml2. Try installing a system libxml2 with `brew install libxml2` and then `bundle config build.nokogiri --use-system-libraries` then again `bundle install`.
6. Create and initialize the database
  - `rails db:create RAILS_ENV=development`
  - `rails db:migrate RAILS_ENV=development`

### Config

Most configuration is set in [config/secrets.yml](https://github.com/brave/publishers/blob/master/config/secrets.yml) via environment variables.

It might be useful to maintain a local bash script with a list of env vars. For an example see [config/secrets.yml](https://github.com/brave/publishers/blob/master/docs/publishers-secrets.example.sh).

#### Automagic addon vars

Some variables are set automagically with Heroku addons:

- FIXIE_URL - Proxy provider. For outbound API requests.
- MAILGUN_* - For sending emails.
- NEW_RELIC_APP_NAME, NEW_RELIC_LICENSE_KEY - New Relic app monitoring.
- REDIS_URL - For Sidekiq and rack-attack

#### Other vars

A few variables are not configured in secrets.yml:

- GPG_PUBKEY - GPG pubkey for encrypting legal forms before uploading to S3.

To develop in offline mode, set:
- `API_EYESHADE_OFFLINE=1`
- `API_LEDGER_OFFLINE=1`

### Run app

- start redis with `redis-server`
- start the app with `foreman start`.  This starts web and workers.

Visit http://localhost:5000 to check it out!

### Testing emails locally

- [mailcatcher](https://github.com/sj26/mailcatcher) runs a local SMTP server and web UI. `gem install mailcatcher` then run `mailcatcher`.
