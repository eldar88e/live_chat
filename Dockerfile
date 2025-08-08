FROM ruby:3.4.4-alpine3.22 AS live_chat

RUN apk --update add --no-cache \
    build-base \
    yaml-dev \
    tzdata \
    yarn \
    libc6-compat \
    postgresql-dev \
    postgresql-client \
    curl \
    libffi-dev \
    ruby-dev \
    vips \
    vips-dev \
    && rm -rf /var/cache/apk/*

ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

WORKDIR /app

COPY Gemfile* ./

RUN gem update --system 3.6.9
RUN gem install bundler -v $(tail -n 1 Gemfile.lock)
RUN bundle check || bundle install --jobs=2 --retry=3
RUN bundle clean --force

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

EXPOSE 3000
