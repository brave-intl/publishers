FROM ruby:2.7-slim

RUN apt-get update -qq && apt-get install -y build-essential

RUN apt-get install -y nodejs \
  libpq-dev \
  git \
  curl \
  libjemalloc2

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y


RUN ["rm", "-rf", "/var/lib/apt/lists/*"]
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

SHELL [ "/bin/bash", "-l", "-c" ]

ENV PATH="/root/.cargo/bin:${PATH}"
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
RUN bundle check || PATH="/root/.cargo/bin:${PATH}" bundle install --without test development --jobs 20 --retry 5
RUN node --version
RUN npm install -g yarn
RUN yarn install --frozen-lockfile

# We copy all the files from the current directory to our
# /app directory
# Pay close attention to the dot (.)
# The first one will select ALL The files of the current directory,
# The second dot will copy it to the WORKDIR!
COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE="1" bundle exec rails assets:precompile DB_ADAPTER=nulldb DATABASE_URL='nulldb://nohost'

EXPOSE 3000
ENTRYPOINT [ "./scripts/entrypoint.sh" ]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-e","${RACK_ENV:-development}"]
