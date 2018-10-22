#!/bin/bash

CHK=$(ls $MAPR_MOUNT_PATH|grep $MAPR_CLUSTER)

while [ "$CHK" == "" ]; do
    echo "Waiting for Posix Mount (2 seconds)"
    sleep 2
    CHK=$(ls $MAPR_MOUNT_PATH|grep $MAPR_CLUSTER)
done

echo "Running: $APP_CMD from env"
$APP_CMD
