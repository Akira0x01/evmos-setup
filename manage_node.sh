#!/bin/bash

# 检查命令行参数的数量
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 {build|start <node>|stop <node>}"
    exit 1
fi

# 读取命令行参数
COMMAND=$1
NODE=""

# 如果命令是start或stop，则检查是否提供了节点编号
if [[ $COMMAND == "start" || $COMMAND == "stop" ]]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 $COMMAND <node>"
        exit 1
    fi
    NODE=$2
    NODE_DIR="${NODE}"

    # 检查节点目录是否存在
    if [ ! -d "${NODE_DIR}" ]; then
        echo "Node directory '${NODE_DIR}' does not exist."
        exit 1
    fi
fi

# 根据参数执行相应的命令
case $COMMAND in
    build)
        echo "Building Docker image..."
        docker build --no-cache --tag vcity/node ./docker --build-arg USERNAME=$USER
        ;;
    start)
        echo "Starting ${NODE}..."
        docker-compose -f ${NODE_DIR}/docker-compose.yml up -d
        ;;
    stop)
        echo "Stopping ${NODE}..."
        docker-compose -f ${NODE_DIR}/docker-compose.yml down
        ;;
    *)
        echo "Invalid command: $COMMAND"
        echo "Usage: $0 {build|start <node>|stop <node>}"
        exit 2
        ;;
esac

exit 0