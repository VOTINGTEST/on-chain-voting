s#!/bin/bash
set -e

(
    if ! git show-ref --verify --quiet "refs/heads/main"; then
        echo "Error: Branch main does not exist."
        exit 1
    fi

    git checkout main
    git pull origin main
)

rm -fr dist
echo "Install dependencies"
rm -rf package-lock.json
yarn install

echo "build"
yarn build:dev

# rsync -av --delete dist/ $PROJECT_PATH/dist/