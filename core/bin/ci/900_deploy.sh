#!/bin/bash
echo "Deploying..."
source "$HOME/.rvm/scripts/rvm"
rvm use --default 1.9.2-p290 || exit 1

echo "deploying to $DEPLOY_SERVER"
cap -S "branch=$GIT_COMMIT" -q $DEPLOY_SERVER deploy || exit 1
echo "deployed to $DEPLOY_SERVER"
exit
