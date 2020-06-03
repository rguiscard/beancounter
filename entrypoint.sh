#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

bundle exec rake db:exists || bundle exec rake db:create

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
