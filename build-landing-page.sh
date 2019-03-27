if git diff --cached --name-status | grep public/creators-landing
then
  cd public/creators-landing && yarn install && yarn build
  cd -
else
   exit 0
fi
