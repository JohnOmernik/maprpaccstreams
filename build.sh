#!/bin/bash

if [ -z "$ENV_FILE" ]; then
    ENV_FILE="./env.list"
fi
echo "Using ENV file: $ENV_FILE"

. $ENV_FILE

MYDIR=$(pwd)

sed -i "s@FROM .*@FROM ${MAPR_PACC_IMG}@g" ./Dockerfile

# Build maprpaccstreams
sudo docker build -t $APP_IMG .

if [ "$?" == "0" ]; then
    echo "Image Build - Sucess!"
else
    echo "Image did not build correctly"
    exit 1
fi
