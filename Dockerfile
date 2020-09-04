FROM ruby:2.7.1-slim

RUN apt-get update -qq && apt-get install -y build-essential

RUN apt-get install -y nodejs \
  libpq-dev \
  git \
  curl

SHELL [ "/bin/bash", "-l", "-c" ]

RUN curl --silent -o-  https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
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
COPY package.json yarn.lock .nvmrc ./

# Install the dependencies.
RUN nvm install && nvm use
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
RUN yarn build

EXPOSE 3000
ENTRYPOINT [ "./scripts/entrypoint.sh" ]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-e","${RACK_ENV:-development}"]

