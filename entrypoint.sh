#!/bin/bash
set -e

# Remove stale server pid file (Rails leaves this behind if the container
# crashed or was killed, and it blocks the server from starting again)
rm -f /aws_practice/tmp/pids/server.pid

# Run database migrations automatically on container start
# This means every time App Runner deploys a new version of your app,
# any new migrations will be applied
bundle exec rails db:prepare

# Hand off to the CMD from the Dockerfile (rails server)
exec "$@"