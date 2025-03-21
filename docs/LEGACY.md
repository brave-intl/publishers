# Legacy Docs - Preserved for Archival/Reference Purposes.

Some content here may be helpful, but this document should be considered out of date.

---

For easy setup read the [running locally with docker-compose](#running-locally-with-docker-compose) section.

Follow these steps to setup the App for [creators.brave.com](https://creators.brave.com). This guide presumes you are using OSX and [Homebrew](https://brew.sh/).

1. Install **Ruby**. For a Ruby version manager try
   [rbenv](https://github.com/rbenv/rbenv). Follow the `Installation` section instructions and ensure your version is at least 1.1.2. Once installed run `rbenv install`. Be sure to restart your terminal before continuing.
2. Install **Node 6.12.3** or greater: `brew install node`
3. Install **Postgresql 9.5+**: `brew install postgresql`

   If you get the error `psql: FATAL: role “postgres” does not exist`. You'll need to create the `/usr/local/opt/postgres/bin/createuser -s postgres`

4. Install **Redis**: `brew install redis`
5. Install **Ruby** gems: `gem install bundler foreman mailcatcher`.
   - [bundler](http://bundler.io/)
   - [foreman](https://github.com/ddollar/foreman)
   - [mailcatcher](https://github.com/sj26/mailcatcher)
6. Install **[Yarn](https://yarnpkg.com/en/)** for Node dependency management: `brew install yarn`
7. Install project dependencies

   **Ruby** dependencies: `bundle install`

   **Possible errors:**

   - Nokogiri, with libxml2. Try installing a system libxml2
     with `brew install libxml2` and then
     `bundle config build.nokogiri --use-system-libraries` then again `bundle install`
   - Run `gem install nokogiri -v '1.10.3'` and then `bundle install`

   **Node** dependencies: `yarn --frozen-lockfile`

   Your version of Node must be v11.15.0 or earlier. For a node version manager, try [NVM](https://github.com/nvm-sh/nvm).

8. Install [git-secrets](https://github.com/awslabs/git-secrets) with `brew install git-secrets` This prevents AWS keys from being committed.
9. (Optional) Get a `.env` file from another developer which contains development-mode env vars. You can start developing without this, but some functionality may be limited.
10. Install **Rails**: `gem install rails`

    **Be sure to restart your terminal before continuing.**

11. Setup SSL as described below.

## HTTPS Setup

Local development of brave-intl uses HTTPS. This allow us to use web APIs such as U2F in development.

If you already have a key and certificate for the `localhost` domain place them in the `ssl/` directory:

```
ssl/server.key
ssl/server.crt
```

If you don't, you will need to generate certificates for this domain:

```
bundle exec rake ssl:generate
```

Note: If you are running in the docker context you can just manually execute the lines found in `lib/tasks/ssl.rake`. The task is just
a convenience wrapper for openssl cert generation.

When you first visit the application in a browser you may need to add an
exception to trust this self-signed certificate. Sometimes this is under an
"advanced" or "proceed" link.

## Run

1. Start **Postgres** and **Redis**: `brew services start redis postgresql`
2. Create and initialize the database:

   ```
   rails db:create RAILS_ENV=development
   rails db:migrate RAILS_ENV=development
   ```

   **Note**: If you receive a `fatal-role` error, try running `/usr/local/opt/postgres/bin/createuser -s postgres` due to being installed from `homebrew`. Further documentation is [here.](https://stackoverflow.com/questions/15301826/psql-fatal-role-postgres-does-not-exist)

   If you receive an error about Readline, try running:

   ```
   ln -s /usr/local/opt/readline/lib/libreadline.dylib /usr/local/opt/readline/lib/libreadline.7.dylib
   ```

   Issue for [further documentation](https://github.com/deivid-rodriguez/byebug/issues/289).

3. Run Rails server and async worker:
   `bundle exec puma -C config/puma.rb -e ${RACK_ENV:-development}`
   `bundle exec sidekiq -C config/sidekiq.yml -e ${RACK_ENV:-development}`

4. Visit https://localhost:3000

5. To test email, run a local mail server with: `mailcatcher`

6. To view the emails sent to your inbox visit: http://localhost:1080

7. Run webpack separately: `./bin/webpack-dev-server`

8. Compile landing page assets: `cd public/landing-page; rake assets:clobber; rake assets:precompile; yarn install; yarn build`

---

## API Setups

### Google API Setup

Setup a google API project:

- Login to your google account (dev), or the Brave google account (staging, production)
- Go to [https://console.developers.google.com](https://console.developers.google.com)
- Select "Create Project" then "Create" to setup a new API project
- Give the project a name such as "creators-dev"
- Select "+ Enable APIs and Services"
- Enable "Google+ API" and "YouTube Data API v3"
- Back at the console select Credentials, then select the "OAuth consent screen" sub tab
- Fill in the details. For development you need the Product name, try "Creators Dev (localhost)"
- Then Select "Create credentials", then "OAuth client ID"
  - Application type is "Web application"
  - Name is "Creators"
  - Authorized redirect URIs is `http://localhost:3000/publishers/auth/google_oauth2/callback`
  - select "Create"
- Record the Client ID and Client secret and enter them in your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` variables
- Back at the console select "Create credentials" and select API key. This will be used for youtube channel stats via the data api.
- Record the API and enter it in your `YOUTUBE_API_KEY` variable

You may need to wait up to 10 minutes for the changes to propagate.

These steps based on [directions at the omniauth-google-oauth2 gem](https://github.com/zquestz/omniauth-google-oauth2#google-api-setup).

### Twitch API Setup

Setup a twitch API project:

- Login to your Twitch account (dev), or the Brave Twitch account (staging, production)
- Go to [https://dev.twitch.tv/dashboard](https://dev.twitch.tv/dashboard)
- Make sure you first set up 2 factor auth for your twitch account
- Select "Register Your Application" under "Applications"
- Give the project a name such as "creators-dev"
- Give the app a name and application category.
- Use the redirect URI `https://localhost:3000/publishers/auth/register_twitch_channel/callback` in development.
- Use the 'Website Integration' category
- Save the app
- Once the application is created, click on "Manage" where you can view the Client ID and create the Client Secret
- Create a Client ID and secret, saving each of them.
  - Update your env to include `TWITCH_CLIENT_ID="your-app-id"`
  - Update your env to include `TWITCH_CLIENT_SECRET="your-app-secret"`

### Twitter API Setup

- Apply for a developer account at [developer.twitter.com](https://developer.twitter.com/)
- Select "Create an App"
- Give the app a name like "Brave Payments Dev"
- Make sure "Enable Sign in with Twitter" is checked
- Set the callback url to `https://localhost:3000/publishers/auth/register_twitter_channel/callback`. If it does not allow you to set `localhost`, use a place holder for now, and later add the correct callback url through apps.twitter.com instead.
- Fill in the remaining information and hit "Create"
- Navigate to your app settings -> permissions and ensure it is readonly and requests the user email
- Regenerate your Consumer API keys
- Update your env to include `TWITCH_CLIENT_ID="your-api-key"` and `TWITTER_CLIENT_SECRET="your-api-secret-key"`
- Save

### reCAPTCHA Setup

In order to test the rate limiting and captcha components you will need to setup an account with Google's
[reCAPTCHA](https://www.google.com/recaptcha/intro/android.html). Instructions can be found at the
[reCAPTCHA gem repo](https://github.com/ambethia/recaptcha#rails-installation). Add the api keys to your Env variables.

### Local Eyeshade Setup

1. Follow the [setup instructions](https://github.com/brave-intl/bat-ledger) for bat-ledger
2. `make eyeshade-integration` To run publishers docker containers with the proper environment variables and network configuration to interact with bat-ledgers
3. `make eyeshade-balances` To Populate eyeshade with balances matching the fixture channels founds in the local database

To stop using Eyeshade just execute `docker-compose stop` and `make docker-dev` to use the isolated network configuration.

### Local Vault-Promo-Services Setup

1. Request access to [Vault-Promo-Services](https://github.com/brave-intl/vault-promo-services) and [ip2tags](https://github.com/brave-intl/vault-promo-services)
2. Follow the [setup instructions](https://github.com/brave-intl/vault-promo-services)
3. Create and run a `vault-promo-services.sh` start script like this

```
export DATABASE_URL="services"
export PGDATABASE="services"
export AUTH_TOKEN=1234
export S3_KEY="X"
export S3_SECRET="x"
export WINIA32_DOWNLOAD_KEY="/"
export WINX64_DOWNLOAD_KEY="/"
export OSX_DOWNLOAD_KEY="/"
export TEST=1

dropdb services
createdb services
for folder in ./migrations/*; do
  psql services < ${folder}/up.sql
done
npm start
```

- If you run into an issue about a missing `.mmdb` file, run `fetch.sh` in `node_modules/ip2tags`

4. Add the following into your Publishers start script

```
export API_PROMO_BASE_URI="http://127.0.0.1:8194"
export API_PROMO_KEY="1234"
```

## Development

See [CONTRIBUTING](CONTRIBUTING.md) before submitting any PRs.

### Config

Configuration is set in [config/secrets.yml](https://github.com/brave/publishers/blob/master/config/secrets.yml) via environment variables.

We use the [dotenv gem](https://github.com/bkeepers/dotenv) to load variables specified in `.env` into the rails app, only in the `development` and `test` environments. This makes sure they are only loaded for the context of the running rails app and that they don't pollute the shell environment.

#### Automagic addon vars

Some variables are set automagically with Heroku addons:

- `MAILGUN_*` - For sending emails.
- `NEW_RELIC_APP_NAME`, `NEW_RELIC_LICENSE_KEY` - New Relic app monitoring.
- `REDIS_URL` - For Sidekiq and rack-attack

### Generating Referral Charts

As part of a view we have a chart on the dashboard. There isn't an easy way to mock this out, so there is a rake task to allow developers to easily test this locally.

You must first have a channel added and the promo activated for this to work.

```sh
rails database_updates:mock_data:populate_promo_stats
```

<img src="docs/promo.png" alt="A picture of the chart generated by the promo server">

#### Other vars

A few variables are not configured in secrets.yml: currently none

## Linting

For Ruby we use [standardrb](https://github.com/testdouble/standard) to standardize our project.

To run simply open the project and run in the terminal

```sh
bundle exec standardrb
```

For Typescript/Stylesheets we use [tslint](https://palantir.github.io/tslint/) and [stylelint](https://github.com/stylelint/stylelint) respectively.

To run simply open the project and run in the terminal

```sh
yarn lint
```

## Testing

If you have Docker set up on your machine you can run all the tests by running:

```sh
make docker-test
```

Alternatively if you have the environment set up on your machine you can run the following steps.

### Ruby

```sh
bin/rake test
```

We use capybara which runs selenium tests, which depends on chromium.
If you don't installed, you'll get an error "can't find chrome binary".
On debian you can install it like:

```sh
sudo apt-get install chromium
```

And on mac with:

```
brew cask install chromium
```

We use [ThumbnailWasm](https://github.com/brave-intl/wasm-thumbnail) to process user uploaded images. You'll need rust installed to compile it, see https://rustup.rs/ for more details.

### Javascript

We use jest for our javascript testing framework. You can run the tests through the following command.

```sh
yarn test
```

## Running locally with docker-compose

First, [install docker and docker compose](https://docs.docker.com/compose/install/).

Check out [publishers](https://github.com/brave-intl/publishers).

You can add any environment variables that need to be set by creating a `.env`
file at the top of the repo. Docker compose will automatically load from this
file when launching services.

First time creation will build the core images and bring up the container stack

```
make
```

See `Makefile` for various options

If you wish to make modifications to the compose files you can place a file named `docker-compose.override.yml` at the
top of the repo. For example you can expose ports on your system for the databases with this
`docker-compose.override.yml`:

```yaml
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

### Docker Compose Network Configuration

Publishers is configured to access the local docker network of `bat-ledgers` (Eyeshade) for cases where you need direct network communication from within the docker container context itself.

To access the `bat-ledgers` via direct network interface. You will need to be running both the `publishers` and `bat-ledgers` docker compose contexts locally (i.e. execute `docker-compose up` in the root of both applicatoins)

To test that the publishers containers have direct network access to `bat-ledgers`:

1. Retrieve the container id

Run `docker ps | grep publishers-web` and retrieve the publishers container id (first value in the output) and use it to attach to the container below

1. Attach to the container

```
docker exec -it <container_id of publishers web> bash
```

1. Confirm HTTP network access

Execute simple GET against the name of the networked container (defined in the docker-compose file of the relevant application. In this case bat-legers).

```
curl eyeshade-web:3002
```

If the network is properly configured you will receive the default healthcheck response from eyeshade "ack". You are now able to access any container in the `ledger` network, i.e. `eyeshade-web`, `eyeshade-consumer`, or `eyeshade-postgres` ([See bat-legders' docker compose file](https://github.com/brave-intl/bat-ledger/blob/master/docker-compose.yml))

### Create the databases

```sh
docker-compose run app yarn install; docker-compose run app rake db:setup; docker-compose run eyeshade-worker sh -c "cd eyeshade && ./bin/migrate-up.sh"
```

### Adding balances to Eyeshade

By default when you create a channel it will not have a balance on Eyeshade, the accounting server. To test wallet code with non nil balances, you must add them first.

** bat-ledgers must be up and running locally in docker for either option to work **

#### Running publishers with Docker Compose - (Recommended)

1. To add random balances to all channel details (Note: as of 3/9/22 only SiteChannelDetails types have been added, but can be extended)

```
make eyeshade-balances
```

#### Running publishers installed on your development machine directly

To add a contribution to a channel account:

```
rails "docker:add_contribution_balance_to_account[youtube#channel:UCOo92t8m-tWKgmw276q7mxw, 200]" # Adds 200 BAT to youtube#channel:UCOo92t8m-tWKgmw276q7mxw
```

To add add a referral balance to an owner account:

```
rails "docker:add_referral_balance_to_account[publishers#uuid:967a9919-34f4-4ce6-af36-e3f592a6eab7, 400]" # Adds 400 BAT to youtube#channel:UCOo92t8m-tWKgmw276q7mxw
```

Balances should be reflected in the dashboard. When using docker-compose the fixture data should be loaded for all available fixture users.

For details on how these are generated see: `lib/docker/eyeshade_helper.rb` for core class and methods, `lib/tasks/docker.rb` for loading data if running `publishers` installed locally, and `lib/tasks/eyeshade.rb` for loading data if you are using docker-compose to develop publishers.

### Adding a new type of channel

The easiest possible way to add a new channel is to find the Omniauth gem for the specified integration. A few examples include [omniauth-soundcloud](https://github.com/soundcloud/omniauth-soundcloud), [omniauth-github](https://github.com/omniauth/omniauth-github), or [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook)

1. Add the gem to the [Gemfile](https://github.com/brave-intl/publishers/blob/staging/Gemfile#L73)
2. Run bundle install
3. Run `rails generate property INTEGRATION_channel_details` (Note: replace `INTEGRATION` with the name of the integration, e.g. github, soundcloud, vimeo, etc)
4. Run `rails db:migrate`
5. Register a new route in [config/initializers/devise.rb](https://github.com/brave-intl/publishers/blob/2019_05_29/config/initializers/devise.rb#L243)
6. Add a new controller method in `app/controllers/publishers/omniauth_callbacks_controller.rb` similar to `register_github_channel` or `register_reddit_channel`
7. Add the link and icon to `/app/views/application/_choose_channel_type.html.slim`
8. Add translations in [en.yml](https://github.com/brave-intl/publishers/blob/staging/config/locales/en.yml) for `helpers.publisher.channel_type` and `helpers.publisher.channel_name`

   ```yaml
   channel_type:
     youtube: YouTube channel
     website: Website
     <INTEGRATION>: Your <INTEGRATION> Name
    channel_name:
      youtube: YouTube
      website: the website
      <INTEGRATION>: <INTEGRATION> Name
   ```

9. Add assets for the new integration. Both a [32x32 png](https://github.com/brave-intl/publishers/tree/staging/app/assets/images/publishers-home) and a [SVG of the logo](https://github.com/brave-intl/publishers/tree/staging/app/assets/images/choose-channel).

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
