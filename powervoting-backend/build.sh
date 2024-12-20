#!/bin/bash
set -e

PORT=""

IMAGE_NAME="power-voting-backend"

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

docker run --name $IMAGE_NAME -v ./configuration.yaml:/dist/configuration.yaml -v proof.ucan:/dist/proof.ucan -p $PORT:$PORT -d $IMAGE_NAME