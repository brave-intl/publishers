#!/bin/bash

set -e
echo "Running container's main process..."
exec "$@"
