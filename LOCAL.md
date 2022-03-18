# Running Locally

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


