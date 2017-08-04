FROM ruby:latest
LABEL maintainer "mvnicosia@gmail.com"

RUN gem install bundler
COPY * ./
RUN bundle install

EXPOSE 8080
CMD rackup server.rb --host 0.0.0.0 --port 8080
