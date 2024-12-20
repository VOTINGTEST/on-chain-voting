#!/bin/bash
set -e

PORT=""

REPO_URL="git@github.com:VOTINGTEST/on-chain-voting.git"
BRANCH_NAME="main"
IMAGE_NAME="power-voting-backend"

(
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

docker build -t $IMAGE_NAME .

if docker ps -a --format '{{.Names}}' | grep -wq "$IMAGE_NAME"; then
    echo "Stopping container: $IMAGE_NAME..."
    docker stop $IMAGE_NAME
    docker rm $IMAGE_NAME

    if [ $? -eq 0 ]; then
        echo "Container $CONTAINER_NAME stopped successfully."
    else
        echo "Failed to stop container $CONTAINER_NAME."
        exit 2
    fi
else
    echo "Container $CONTAINER_NAME does not exist or is already stopped."
fi

docker run --name $IMAGE_NAME -v configuration.yaml:/dist/configuration.yaml -v proof.ucan:/dist/proof.ucan -p $PORT:$PORT -d $IMAGE_NAME