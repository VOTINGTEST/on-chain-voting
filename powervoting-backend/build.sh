#!/bin/bash
set -e

CONFIG_FILE="configuration.yaml"

IMAGE_NAME="power-voting-backend"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE does not exist."
    exit 1
fi

PORT=$(awk '/^server:/{flag=1;next} /^  port:/{if(flag) print $2; flag=0}' "$CONFIG_FILE" | tr -d ':')

if [ -z "$PORT" ]; then
  echo "未能从配置文件中读取 port 值！"
  exit 1
fi

echo "project: $IMAGE_NAME, port: $PORT"

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

docker run --name $IMAGE_NAME -v ./configuration.yaml:/dist/configuration.yaml -v proof.ucan:/dist/proof.ucan -p $PORT:$PORT -d $IMAGE_NAME