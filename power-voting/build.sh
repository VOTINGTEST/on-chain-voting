s#!/bin/bash
set -e

REPO_URL=""
BRANCH_NAME=""

CODE_PATH=""
PROJECT_PATH=""

# 设置 ssh key
eval $(ssh-agent)
ssh-add $KEY_FILE_PATH

# 拉取指定仓库的 dev 分支
(
    cd $CODE_PATH 
    if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        # dev 分支不存在，报错并退出
        echo "Error: Branch $BRANCH_NAME does not exist."
        exit 1
    fi

    # 切换到 dev 分支并获取最新代码
    git checkout $BRANCH_NAME
    git pull origin $BRANCH_NAME

    # 检查是否有新增的 commit
    if git diff --quiet HEAD $BRANCH_NAME; then
        echo "No new commits. Exiting script."
        exit 0
    fi
    wait
)

# 关闭ssh agent
#eval $(ssh-agent -k)

# 构建镜像
cd $CODE_PATH/power-voting
rm -fr dist
echo "Install dependencies"
rm -rf package-lock.json
yarn install

echo "build"
yarn build:dev

rsync -av --delete dist/ $PROJECT_PATH/dist/