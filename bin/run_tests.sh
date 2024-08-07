#!/bin/bash

set -e

echo "Running the Next.js server in test mode"
(cd nextjs && NODE_TLS_REJECT_UNAUTHORIZED=0 TEST_MODE=true TEST_MODE_PUBLISHERS_HOST=localhost:4000 TEST_MODE_NEXT_HOST=localhost:5001 NODE_ENV=development npm run dev 2>&1 > ../log/nextjstest.log) &

echo "Running only the tests in the system/nextjs folder"
NEXT_HOST=localhost:5001 bundle exec rails test test/system/nextjs

echo "Running all tests except those in the system/nextjs folder"
bundle exec rails test --exclude /test/system/nextjs/  # the / / around the folder path are for regex
