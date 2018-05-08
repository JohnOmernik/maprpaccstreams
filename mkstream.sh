#!/bin/bash

. ./env.list

POSIX_MNT="${MAPR_MOUNT_PATH}/${MAPR_CLUSTER}"
POSIX_VOL="${POSIX_MNT}${MAPR_STREAMS_VOLUME_LOCATION}"
POSIX_STREAM="${POSIX_MNT}${MAPR_STREAMS_STREAM_LOCATION}"

MAPRCLI="maprcli"
#MAPRCLI="/home/zetaadm/homecluster/zetago/zeta fs mapr maprcli -U=mapr"
if [ ! -d "$POSIX_VOL" ]; then
    echo "Volume not detected at $POSIX_VOL: Creating"
    $MAPRCLI volume create -path $MAPR_STREAMS_VOLUME_LOCATION -rootdirperms 775 -user "${MAPR_CONTAINER_USER}:fc,a,dump,restore,m,d mapr:fc,a,dump,restore,m,d" -ae $MAPR_CONTAINER_USER -name "$MAPR_STREAMS_VOLUME_NAME"

    if [ "$?" == "0" ]; then
        echo "Volume Created successfully"
    else
        echo "Volume Creation failed: Exiting"
        exit 1
    fi
else
    echo "Volume already exists"
fi

echo ""
if [ ! -L "$POSIX_STREAM" ]; then
    echo "Stream not detected at $POSIX_STREAM: Creating"
    $MAPRCLI stream create -path $MAPR_STREAMS_STREAM_LOCATION -defaultpartitions $MAPR_STREAMS_DEFAULT_PARTITIONS -produceperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)" -consumeperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)" -topicperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)" -adminperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)"
    if [ "$?" == "0" ]; then
        echo "Stream Created Successfully"
        echo "Creating Topic"
        $MAPRCLI stream topic create -path $MAPR_STREAMS_STREAM_LOCATION -topic $MAPR_STREAMS_TOPIC
    else
        echo "Stream Creation failed"
    fi
else
    echo "Stream location already exists"
fi
rm -rf ./conf
