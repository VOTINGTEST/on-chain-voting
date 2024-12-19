#!/bin/bash
set -e

REPO_URL=""
BRANCH_NAME=""

IMAGE_NAME=""
PROJECET_PATH=""
CONFIG_PATH=""
CONFIG_FILE=""
CODE_PATH=""
PORT=""
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
    exit 1
fi
wait
)

(cd $PROJECET_PATH && docker build -t $IMAGE_NAME .)

if docker ps -a --format '{{.Names}}' | grep -wq "$IMAGE_NAME"; then
    echo "Stopping container: $IMAGE_NAME..."
    docker stop $IMAGE_NAME
    docker rm $IMAGE_NAME

    if [ $? -eq 0 ]; then
        echo "Container $CONTAINER_NAME stopped successfully."
    else
        echo "Failed to stop container $CONTAINER_NAME."
        exit 1
    fi
else
    echo "Container $CONTAINER_NAME does not exist or is already stopped."
fi


docker run --name $IMAGE_NAME -v $CONFIG_PATH/$CONFIG_FILE:/dist/configuration.yaml -p $PORT:$PORT -d $IMAGE_NAME