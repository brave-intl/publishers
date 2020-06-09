FROM ruby:2.7.1

# Install node
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN node --version
RUN npm --version

RUN gem install bundler
RUN npm install -g yarn

# Enabling app reloading based off of https://stackoverflow.com/questions/37699573/rails-app-in-docker-container-doesnt-reload-in-development
# Sets the path where the app is going to be installed
ENV RAILS_ROOT /var/www/

# Creates the directory and all the parents (if they don't exist)
RUN mkdir -p $RAILS_ROOT

# This will be the de-facto directory where all the contents are going to be stored.
WORKDIR $RAILS_ROOT

# We are copying the Gemfile first, so we can install
# all the dependencies without any issues
# Rails will be installed once you load it from the Gemfile
# This will also ensure that gems are cached and only updated when they change.
COPY Gemfile ./
COPY Gemfile.lock ./

# Install the gems.
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

# We copy all the files from the current directory to our
# /app directory
# Pay close attention to the dot (.)
# The first one will select ALL The files of the current directory,
# The second dot will copy it to the WORKDIR!
COPY . .
RUN bundle install

RUN yarn install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
