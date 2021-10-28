FROM ruby:3.0.2
LABEL maintainer "mvnicosia@gmail.com"

RUN gem install bundler
COPY * ./
RUN bundle install

EXPOSE 9292
CMD rackup server.rb
