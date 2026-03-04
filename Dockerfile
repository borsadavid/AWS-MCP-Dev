FROM ruby:3.0.7

# Install system dependencies
# - build-essential: compilers for native gem extensions
# - libpq-dev: lets the 'pg' gem talk to Postgres
# - nodejs: needed for the Rails asset pipeline
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /aws_practice

# Copy Gemfile first (Docker caches this layer — if Gemfile didn't change,
# it skips bundle install on rebuilds, saving tons of time)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Now copy the rest of your app
COPY . .

# Compile CSS/JS into static files for production
# SECRET_KEY_BASE_DUMMY=1 is a Rails trick — asset compilation doesn't
# need a real secret, so we use a dummy to avoid errors
RUN SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile

# Copy and enable the entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]