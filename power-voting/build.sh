s#!/bin/bash
set -e

REPO_URL=""
BRANCH_NAME=""

CODE_PATH=""
PROJECT_PATH=""

(
    cd $CODE_PATH 
    if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        echo "Error: Branch $BRANCH_NAME does not exist."
        exit 1
    fi

    git checkout $BRANCH_NAME
    git pull origin $BRANCH_NAME

    if git diff --quiet HEAD $BRANCH_NAME; then
        echo "No new commits. Exiting script."
        exit 0
    fi
    wait
)

cd $CODE_PATH/power-voting
rm -fr dist
echo "Install dependencies"
rm -rf package-lock.json
yarn install

echo "build"
yarn build:dev

rsync -av --delete dist/ $PROJECT_PATH/dist/