App for [publishers.brave.com](https://publishers.brave.com).

[![Build Status](https://travis-ci.org/brave-intl/publishers.svg?branch=master)](https://travis-ci.org/brave-intl/publishers)

## Quick start

### Setup

These steps presume you are using OSX and [Homebrew](https://brew.sh/).

1. Ruby 2.3.7. For a Ruby version manager try
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
      `bundle install`.,.
  * Node deps: `yarn --frozen-lockfile`
8. (Optional) Get an `env.sh` file from another developer which contains development-mode
   bash env exports and `source` that file. You can start developing without this, but some functionality may be limited.
9. Create and initialize the database:
  - `rails db:create RAILS_ENV=development`
  - `rails db:migrate RAILS_ENV=development`
10. Setup SSL as described below.

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
* Back at the console select "Create credentials" and select API key.  This will be used for youtube channel stats via the data api.
* Record the API and enter it in your Env variables

You may need to wait up to 10 minutes for the changes to propagate.

These steps based on [directions at the omniauth-google-oauth2 gem](https://github.com/zquestz/omniauth-google-oauth2#google-api-setup).

### Twitch API Setup

Setup a twitch API project:

* Login to your Twitch account (dev), or the Brave Twitch account (staging, production)
* Go to [https://dev.twitch.tv/dashboard](https://dev.twitch.tv/dashboard)
* Select "Get Started" for "App"
* Give the project a name such as "publishers-dev"
* Give the app a name and application category.
* Use the redirect URI `https://localhost:3000/publishers/auth/register_twitch_channel/callback` in development.
* Create a Client ID and secret, saving each of them.
  * Update your env to include `TWITCH_CLIENT_ID="your-app-id"`
  * Update your env to include `TWITCH_CLIENT_SECRET="your-app-secret"`
* Save the app

### Twitter API Setup

* Apply for a developer account at [developer.twitter.com](https://developer.twitter.com/)
* Select "Create an App"
* Give the app a name like "Brave Payments Dev"
* Make sure "Enable Sign in with Twitter" is checked
* Set the callback url to `https://localhost:3000/publishers/auth/register_twitter_channel/callback`.  If it does not allow you to set `localhost`, use a place holder for now, and later add the correct callback url through apps.twitter.com instead.
* Fill in the remaining information and hit "Create"
* Navigate to your app settings -> permissions and ensure it is readonly and requests the user email
* Regenerate your Consumer API keys
* Update your env to include `TWITCH_CLIENT_ID="your-api-key"` and `TWITTER_CLIENT_SECRET="your-api-secret-key"`
* Save

### reCAPTCHA Setup

In order to test the rate limiting and captcha components you will need to setup an account with Google's
[reCAPTCHA](https://www.google.com/recaptcha/intro/android.html). Instructions can be found at the
[reCAPTCHA gem repo](https://github.com/ambethia/recaptcha#rails-installation). Add the api keys to your Env variables.

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

## Running locally with docker-compose

First, [install docker and docker compose](https://docs.docker.com/compose/install/).

Check out [publishers](https://github.com/brave-intl/publishers).

In a sibling directory check out [bat-ledger](https://github.com/brave-intl/bat-ledger).

You can add any environment variables that need to be set by creating a `.env`
file at the top of the repo. Docker compose will automatically load from this
file when launching services.

e.g. you might have the following in `.env`:
```
BAT_MEDIUM_URL=https://medium.com/@attentiontoken
BAT_REDDIT_URL=https://www.reddit.com/r/BATProject/
BAT_ROCKETCHAT_URL=https://basicattentiontoken.rocket.chat/
BAT_TWITTER_URL=https://twitter.com/@attentiontoken
DEFAULT_API_PAGE_SIZE=600

GOOGLE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
GOOGLE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
GOOGLE_CLIENT_ID=somelongkey.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=mysecret
GOOGLE_PROJECT_ID=bravedev-184414
GOOGLE_TOEKN_URI=https://accounts.google.com/o/oauth2/token

RECAPTCHA_PRIVATE_KEY=my_recaptcha_key
RECAPTCHA_PUBLIC_KEY=my_recaptcha_publickey
RECAPTCHA_SECRET_KEY=my_recaptcha_secretkey
RECAPTCHA_SITE_KEY=my_recaptcha_sitekey

SENDGRID_API_KEY=SG.toke
SENDGRID_PUBLISHERS_LIST_ID=3648346

TWITCH_CLIENT_ID=twitch_client_id
TWITCH_CLIENT_SECRET=my_twitch_secret

UPHOLD_API_URI=https://api-sandbox.uphold.com
UPHOLD_CLIENT_ID=my_dev_uphold_client_id
UPHOLD_CLIENT_SECRET=my_dev_uphold_client_secret
UPHOLD_PROVIDER=api-sandbox.uphold.com
UPHOLD_SCOPE=cards:read,user:read,transactions:transfer:others

```

If you wish to make modifications to the compose files you can place a file named `docker-compose.override.yml` at the 
top of the repo. For example you can expose ports on your system for the databases with this 
`docker-compose.override.yml`:

```
version: "2.1"

services:
  mongo:
    ports:
      - "27017:27017"
  redis:
    ports:
      - "6379:6379"
  postgres:
    ports:
      - "5432:5432"
```

to start with docker build the app and eyeshade images
```sh
docker-compose build
```

and bring up the full stack
```sh
docker-compose up
```

### Create the databases
```sh
docker-compose run app rake db:setup; docker-compose run eyeshade-worker sh -c "cd eyeshade && ./bin/migrate-up.sh"
```

### Run Tests

Tests can be run on the container with
```sh
docker-compose run app rake test
```

Other one off commands can be run as above, but replacing `rake test`. Note this spawns a new container.

### Debugging
Debugging with byebug and pry can be done by attaching to the running process. First get the container 
id with `docker ps`

```sh
docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED                  STATUS              PORTS                                            NAMES
234f116cd942        publishers_app           "foreman start --pro…"   Less than a second ago   Up 2 seconds        0.0.0.0:3000->3000/tcp                           publishers_app_1
b592d489a8d3        redis                    "docker-entrypoint.s…"   15 minutes ago           Up 3 seconds        6379/tcp                                         publishers_redis_1
f1c86172def7        schickling/mailcatcher   "mailcatcher --no-qu…"   15 minutes ago           Up 2 seconds        0.0.0.0:1025->1025/tcp, 0.0.0.0:1080->1080/tcp   publishers_mailcatcher_1
```

Then attach to the container and you will hit your `binding.pry` breakpoints

```sh
docker attach 234f116cd942
```

To connect with a bash shell on a running container use:
```sh
docker exec -i -t 234f116cd942 /bin/bash
root@234f116cd942:/var/www# 
```
