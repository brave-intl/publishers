App for [publishers.brave.com](https://publishers.brave.com).

[![Build Status](https://travis-ci.org/brave-intl/publishers.svg?branch=master)](https://travis-ci.org/brave-intl/publishers)

## Quick start

### Setup

These steps presume you are using OSX and [Homebrew](https://brew.sh/).

1. Ruby 2.3.6. For a Ruby version manager try
   [rbenv](https://github.com/rbenv/rbenv).
2. Node 6.12.3 (active LTS at writing) or greater. For a Node version manager
   try [nvm](https://github.com/creationix/nvm#installation).
3. Postgresql 9.5+: `brew install postgresql` (start with
   `brew services start postgresql`)
4. Redis: `brew install redis`
5. Install Ruby gems with `gem install bundler foreman mailcatcher`.
   - [bundler](http://bundler.io/)
   - [foreman](https://github.com/ddollar/foreman)
   - [mailcatcher](https://github.com/sj26/mailcatcher)
6. [Yarn](https://yarnpkg.com/en/) for Node dependency management:
   `brew install yarn --without-node`.
   `--without-node` avoids installing Homebrew's version of Node, which is
   desirable if you are using nvm for Node version management.
7. Install project dependencies
  * Ruby deps: `bundle install --jobs=$(nproc)`
    - Possible error: Nokogiri, with libxml2. Try installing a system libxml2
      with `brew install libxml2` and then
      `bundle config build.nokogiri --use-system-libraries` then again
      `bundle install`.
  * Node deps: `yarn --frozen-lockfile`
8. Get an `env.sh` file from another developer which contains development-mode
   bash env exports. `source` that file.
9. Create and initialize the database
  - `rails db:create RAILS_ENV=development`
  - `rails db:migrate RAILS_ENV=development`

### HTTPS Setup

Local development of brave-intl uses HTTPS. This allow us to use web APIs such
as U2F in development.

If you already have a key and certificate for the `localhost` domain place them in the
`ssl/` directory:

```
ssl/server.key
ssl/server.crt
```

If you don't, you will need to generate certificates for this domain:

```
bundle exec rake ssl:generate
```

When you first visit the application in a browser you may need to add an
exception to trust this self-signed certificate. Sometimes this is under an
"advanced" or "proceed" link.

### Google API Setup

Setup a google API project:

* Login to your google account (dev), or the Brave google account (staging, production)
* Go to [https://console.developers.google.com](https://console.developers.google.com)
* Select "Create Project" then "Create" to setup a new API project
* Give the project a name such as "publishers-dev"
* Select "+ Enable APIs and Services"
* Enable "Google+ API" and "YouTube Data API v3"
* Back at the console select Credentials, then select the "OAuth consent screen" sub tab
* Fill in the details. For development you need the Product name, try "Publishers Dev (localhost)"
* Then Select "Create credentials", then "OAuth client ID"
  * Application type is "Web application"
  * Name is "Publishers"
  * Authorized redirect URIs is `http://localhost:3000/publishers/auth/google_oauth2/callback`
  * select "Create"
* Record the Client ID and Client secret and enter them in your Env variables

You may need to wait up to 10 minutes for the changes to propagate.

These steps based on [directions at the omniauth-google-oauth2 gem](https://github.com/zquestz/omniauth-google-oauth2#google-api-setup).

### Twitch API Setup

Setup a google API project:

* Login to your Twitch account (dev), or the Brave Twitch account (staging, production)
* Go to [https://dev.twitch.tv/dashboard](dev.twitch.tv/dashboard)
* Select "Get Started" for "App"
* Give the project a name such as "publishers-dev"
* Give the app a name and application category.
* Use the redirect URI `https://localhost:3000/publishers/auth/register_twitch_channel/callback` in development.
* Create a Client ID and secret, saving each of them.
  * Update your env to include `TWITCH_CLIENT_ID="your-app-id"`
  * Update your env to include `TWITCH_CLIENT_SECRET="your-app-secret"`
* Save the app

### Local Eyeshade Setup

1. Follow the [setup instructions](https://github.com/brave-intl/bat-ledger) for bat-ledger
2. Add `export API_EYESHADE_BASE_URI="http://127.0.0.1:3002"` to your secrets script
3. Add `export API_EYESHADE_KEY="00000000-0000-4000-0000-000000000000"` to your secrets script

To stop using Eyeshade locally, set `API_EYESHADE_BASE_URI=""`.

### Run

1. Start Postgres and redis.

2. Run Rails server and async worker
`foreman start -f Procfile.dev`

3. Visit https://localhost:3000

4. To test email, run a local mail server at localhost:25
`mailcatcher`

## Development

### Config

Configuration is set in [config/secrets.yml](https://github.com/brave/publishers/blob/master/config/secrets.yml) via environment variables.

It might be useful to maintain a local bash script with a list of env vars. For an example see [config/secrets.yml](https://github.com/brave/publishers/blob/master/docs/publishers-secrets.example.sh).

#### Automagic addon vars

Some variables are set automagically with Heroku addons:

- `FIXIE_URL` - Proxy provider. For outbound API requests.
- `MAILGUN_*` - For sending emails.
- `NEW_RELIC_APP_NAME`, `NEW_RELIC_LICENSE_KEY` - New Relic app monitoring.
- `REDIS_URL` - For Sidekiq and rack-attack

#### Other vars

A few variables are not configured in secrets.yml: currently none

## Testing

```sh
bin/rake test
```

We use capybara which runs selenium tests, which depends on chromium.
If you don't installed, you'll get an error "can't find chrome binary".
On debian you can install it like:

```sh
sudo apt-get install chromium
```
