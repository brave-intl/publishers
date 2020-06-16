FROM ruby:2.7.1-alpine

RUN apk add --update --no-cache \
  bash \
  binutils-gold \
  build-base \
  curl \
  file \
  g++ \
  gcc \
  git \
  less \
  libstdc++ \
  libffi-dev \
  libc-dev \
  linux-headers \
  libxml2-dev \
  libxslt-dev \
  libgcrypt-dev \
  make \
  netcat-openbsd \
  openssl \
  pkgconfig \
  postgresql-dev \
  python \
  tzdata \
  yarn

RUN gem install bundler

RUN NODE_ENV=production
RUN RAILS_ENV=production


WORKDIR /var/www/

# We are copying the Gemfile first, so we can install
# all the dependencies without any issues
# Rails will be installed once you load it from the Gemfile
# This will also ensure that gems are cached and only updated when they change.
COPY Gemfile ./
COPY Gemfile.lock ./
COPY package.json yarn.lock ./

# Install the gems.
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle check || bundle install --jobs 20 --retry 5
RUN yarn install --frozen-lockfile

# We copy all the files from the current directory to our
# /app directory
# Pay close attention to the dot (.)
# The first one will select ALL The files of the current directory,
# The second dot will copy it to the WORKDIR!
COPY . .

RUN yarn build
RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails","server","-b","0.0.0.0","-p","3000"]
