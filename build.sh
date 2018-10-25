#!/bin/bash

if [ -z "$ENV_FILE" ]; then
    ENV_FILE="./env.list"
fi
echo "Using ENV file: $ENV_FILE"

. $ENV_FILE

MYDIR=$(pwd)

OUTLINE=""
OUTLINEG=""

for U in $MAPR_USER_LIST; do
    U_NAME=$(echo -n "$U"|cut -d":" -f1)
    U_ID=$(echo -n "$U"|cut -d":" -f2)

    if [ "$U_ID" == "" ]; then
        echo "Could not find user id for $U exiting"
        exit 1
    else
        if [ "$OUTLINE" == "" ]; then
            OUTLINE="RUN adduser --disabled-login --gecos '' --uid=${U_ID} ${U_NAME}"
            OUTLINEG="RUN usermod -a -G root ${U_NAME} \&\& usermod -a -G adm ${U_NAME} \&\& usermod -a -G disk ${U_NAME}"
        else
            OUTLINE="${OUTLINE} \&\& adduser --disabled-login --gecos '' --uid=${U_ID} ${U_NAME}"
            OUTLINEG="${OUTLINEG} \&\& usermod -a -G root ${U_NAME} \&\& usermod -a -G adm ${U_NAME} \&\& usermod -a -G disk ${U_NAME}"
        fi
    fi
done
if [ "$OUTLINE" == "" ]; then
    sed -i -r "s@^RUN adduser.*@# RUN adduser @" ./Dockerfile
    sed -i -r "s@^RUN usermod.*@# RUN usermod @" ./Dockerfile
else
    sed -i -r "s@^RUN adduser.*@# RUN adduser @" ./Dockerfile
    sed -i -r "s@^RUN usermod.*@# RUN usermod @" ./Dockerfile
    sed -i "s@# RUN adduser.*@$OUTLINE@" ./Dockerfile
    sed -i "s@# RUN usermod.*@$OUTLINEG@" ./Dockerfile
fi

sed -i "s@FROM .*@FROM ${MAPR_PACC_IMG}@g" ./Dockerfile

if [ "$MAPR_INCLUDE_LDAP" == "1" ]; then
    sed -i "s/ libnss3 libpam-ldap nscd//g" ./Dockerfile
    sed -i "s/ git/ git libnss3 libpam-ldap nscd/g" ./Dockerfile
    # Setup LDAP information for OpenLDAP
    echo "base ${MAPR_LDAP_BASE}" > ./ldap.conf
    echo "uri ${MAPR_LDAP_URL}" >> ./ldap.conf
    echo "binddn ${MAPR_LDAP_RO_USER}" >> ./ldap.conf
    echo "bindpw ${MAPR_LDAP_RO_PASS}" >> ./ldap.conf
    echo "ldap_version 3" >> ./ldap.conf
    echo "pam_password md5" >> ./ldap.conf
    echo "bind_policy soft" >> ./ldap.conf

    sed -i "s@# ADD ./ldap.conf@ADD ./ldap.conf@g" ./Dockerfile
    sed -i "s@# RUN DEBIAN_FRONTEND@RUN DEBIAN_FRONTEND@g" ./Dockerfile
else
    sed -i "s/ libnss3 libpam-ldap nscd//g" ./Dockerfile
    sed -i -r "s@^ADD ./ldap.conf@# ADD ./ldap.conf@g" ./Dockerfile
    sed -i -r "s@^RUN DEBIAN_FRONTEND@# RUN DEBIAN_FRONTEND@g" ./Dockerfile
fi





# Build maprpaccstreams
sudo docker build -t $APP_IMG .

if [ "$?" == "0" ]; then
    echo "Image Build - Success!"
else
    echo "Image did not build correctly"
    exit 1
fi
