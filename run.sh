#!/bin/bash

. ./env.list

MYDIR=$(pwd)
CODEDIR="$MYDIR/code"

PORTS=""
VOLS="-v=/tmp/mapr_ticket:/tmp/mapr_ticket:ro -v=${CODEDIR}:/app/code"

sudo docker run -it $PORTS --env-file ./env.list $VOLS \
   --device /dev/fuse \
   --cap-add SYS_ADMIN \
   --cap-add SYS_RESOURCE \
   --security-opt apparmor:unconfined \
   $IMG /bin/bash
