FROM ruby:2.7-alpine

RUN addgroup -S limited_user_group && adduser -S limited_user -G limited_user_group && \ apk update; apk add build-base \
  libpq \
  git \
  curl \
  imagemagick \
  nodejs \
  npm \
  postgresql-client \
  postgresql-dev;

RUN echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile
RUN gem pristine --all; gem install nokogiri bundler

WORKDIR /var/www/

# We are copying the Gemfile first, so we can install
# all the dependencies without any issues
# Rails will be installed once you load it from the Gemfile
# This will also ensure that gems are cached and only updated when they change.
COPY Gemfile ./
COPY Gemfile.lock ./
COPY package.json yarn.lock ./

# Install the dependencies.
RUN bundle check || bundle install --jobs 20 --retry 5
RUN node --version
RUN npm install -g yarn
RUN yarn install --frozen-lockfile

# We copy all the files from the current directory to our
# /app directory
# Pay close attention to the dot (.)
# The first one will select ALL The files of the current directory,
# The second dot will copy it to the WORKDIR!
COPY . .

RUN bundle exec rails assets:precompile

EXPOSE 3000
ENTRYPOINT [ "./scripts/entrypoint.sh" ]
USER limited_user
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-e","${RACK_ENV:-development}"]
