#!/bin/bash

set -e

echo "Running only the tests in the system/nextjs folder"
rails test test/system/nextjs

echo "Running all tests except those in the system/nextjs folder"
bundle exec rails test --exclude /test/system/nextjs/  # the / / around the folder path are for regex
