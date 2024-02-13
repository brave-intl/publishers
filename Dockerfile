# Make sure it matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION

# Install JavaScript dependencies and libvips for Active Storage
ARG NODE_MAJOR_VERSION=20
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x | bash -
RUN apt-get update -qq && \
    apt-get install -y build-essential libvips nodejs libsodium23 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man && \
    npm install -g yarn

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Now for Node/Yarn
COPY package.json yarn.lock ./
RUN npm install -g yarn
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN NODE_OPTIONS=--openssl-legacy-provider RAILS_ENV=production CREATORS_FULL_HOST="1" SECRET_KEY_BASE="1" bundle exec rails assets:precompile DB_ADAPTER=nulldb DATABASE_URL='nulldb://nohost'

# Now compile the homepage
RUN cd public/creators-landing && yarn install && yarn build

# Now for the NextJS frontend
WORKDIR /rails/nextjs
RUN npm i
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build

WORKDIR /rails

# Entrypoint prepares database and starts app on 0.0.0.0:3000 by default,
# but can also take a rails command, like "console" or "runner" to start instead.
EXPOSE 3000
ENTRYPOINT [ "./scripts/entrypoint.sh" ]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-e","${RACK_ENV:-development}"]
