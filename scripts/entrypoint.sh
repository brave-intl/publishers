#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

echo "Running rake app_initializer:setup..."
bundle exec rake app_initializer:setup

# Then exec the container's main process (what's set as CMD in the Dockerfile).
echo "Running container's main process..."
exec "$@"
