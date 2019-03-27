echo "Running script"
if git diff --cached --name-status | grep public/creators-landing
then
  echo "Running the build"
  cd public/creators-landing && yarn install && yarn build
  cd -
  exit 0
else
  echo "Exiting!"
  exit 0
fi
