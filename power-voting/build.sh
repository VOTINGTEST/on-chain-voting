s#!/bin/bash
set -e

(
    if ! git show-ref --verify --quiet "refs/heads/main"; then
        echo "Error: Branch main does not exist."
        exit 1
    fi

    git checkout main
    git pull origin main

    if git diff --quiet HEAD main; then
        echo "No new commits. Exiting script."
        exit 0
    fi
    wait
)

rm -fr dist
echo "Install dependencies"
rm -rf package-lock.json
yarn install

echo "build"
yarn build:dev

# rsync -av --delete dist/ $PROJECT_PATH/dist/