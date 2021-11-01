FROM ruby:3.0.2
LABEL maintainer "mvnicosia@gmail.com"

RUN gem install bundler
COPY . /
RUN bundle install

ENV PORT=8080
EXPOSE $PORT
CMD bundle exec puma -C config/puma.rb
