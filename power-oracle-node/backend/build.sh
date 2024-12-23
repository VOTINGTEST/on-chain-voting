#!/bin/bash
set -e

PORT=$1

IMAGE_NAME="power-voting-oracle-backend"

(
    if ! git show-ref --verify --quiet "refs/heads/main"; then
        echo "Error: Branch main does not exist."
        exit 1
    fi

    git checkout main
    git pull origin main
)

docker build -t $IMAGE_NAME .

if docker ps -a --format '{{.Names}}' | grep -wq "$IMAGE_NAME"; then
    echo "Stopping container: $IMAGE_NAME..."
    docker stop $IMAGE_NAME
    docker rm $IMAGE_NAME
else
    echo "Container $IMAGE_NAME does not exist or is already stopped."
fi


docker run --name $IMAGE_NAME -v ./configuration.yaml:/dist/configuration.yaml -p $PORT:$PORT -d $IMAGE_NAME