#!/bin/bash
git secrets &> /dev/null
if [ $? -ne 0 ]; then
    echo ""
    echo "Could not run git secrets, this is a required commit hook to ensure that our AWS secrets do not get pushed up to Github."
    echo "Try fix this try running:"
    echo ""
    echo -e "brew install git-secrets"
    echo ""

    exit 1
fi

# exit when any command fails
set -e
git secrets --pre_commit_hook

if git diff --cached --name-status | grep public/creators-landing
then
  echo "Building the landing page"
  cd public/creators-landing && yarn install && yarn build
  cd -
  git add public/
  exit 0
else
  exit 0
fi
