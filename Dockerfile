FROM ruby:2.6.5-alpine AS gem

ENV RAILS_ENV production

WORKDIR /myapp

RUN apk add --update --no-cache nodejs yarn postgresql-client postgresql-dev tzdata build-base libidn-dev

# install essential gems
COPY Gemfile.essential .
COPY Gemfile.essential.lock .
RUN bundle install --gemfile=Gemfile.essential --deployment --without development test

# install extra gems
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --deployment --without development test

# install npm packages
COPY package.json .
COPY yarn.lock .
RUN yarn install --frozen-lockfile

# compile assets
ENV RAILS_ENV docker_build
ENV NODE_ENV production
COPY . /myapp
# Assets, to fix missing secret key issue during building
RUN SECRET_KEY_BASE=dumb bundle exec rails assets:precompile \
&& find vendor/bundle -name "*.c" -delete \
&& find vendor/bundle -name "*.o" -delete

FROM ruby:2.6.5-alpine

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVE_STATIC_FILES 1

WORKDIR /myapp

RUN apk add --update --no-cache postgresql-client postgresql-dev tzdata libidn-dev libxml2-dev libxslt-dev python3-dev

# install at system level
RUN gem install --no-document foreman

# install beancounter
RUN pip3 install beancount

COPY . /myapp
COPY --from=gem /usr/local/bundle /usr/local/bundle
COPY --from=gem /myapp/vendor/bundle /myapp/vendor/bundle
COPY --from=gem /myapp/public/assets /myapp/public/assets
COPY --from=gem /myapp/public/packs /myapp/public/packs

# For some reasion, dockerignore does not work properly
RUN rm -rf test \
&& rm -rf vendor/bundle/ruby/2.6.0/cache \
&& rm -rf README.md

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

WORKDIR /myapp
# For puma
RUN mkdir -p tmp/pids
# Start the main process.
CMD ["foreman", "start", "-p", "3000"]
