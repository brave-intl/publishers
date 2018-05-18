FROM ruby:2.3.5

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libxml2
RUN mkdir /usr/src/publishers

COPY . /usr/src/publishers
WORKDIR /usr/src/publishers

RUN gem install bundler foreman mailcatcher

RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
RUN npm install -g yarn
RUN yarn
