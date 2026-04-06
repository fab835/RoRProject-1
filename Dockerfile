# syntax=docker/dockerfile:1

FROM ruby:3.3.11-alpine

WORKDIR /app

RUN apk add --no-cache \
  bash \
  build-base \
  git \
  libpq-dev \
  postgresql-client \
  tzdata \
  yaml-dev

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
