FROM maprtech/pacc:6.1.0_6.0.0_ubuntu16

# Install a bunch of tools for compiling Only doing Python3 now

ENV MAPR_STREAMS_PYTHON="http://package.mapr.com/releases/MEP/MEP-6.0.0/mac/mapr-streams-python-0.11.0.tar.gz"

RUN adduser --disabled-login --gecos '' --uid=2000 mapr && adduser --disabled-login --gecos '' --uid=2500 zetaadm
RUN usermod -a -G root mapr && usermod -a -G adm mapr && usermod -a -G disk mapr && usermod -a -G root zetaadm && usermod -a -G adm zetaadm && usermod -a -G disk zetaadm



RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
              nano vim git libnss3 libpam-ldap nscd \
              python3 python3-dev python3-setuptools python3-pip build-essential \
              zlib1g-dev libssl-dev libsasl2-dev liblz4-dev libsnappy1v5 libsnappy-dev liblzo2-2 liblzo2-dev \
              python-docutils \
         && rm -rf /var/lib/apt/lists/* && rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python && ln -s /usr/bin/pip3 /usr/bin/pip

RUN ln -s /opt/mapr/lib/librdkafka_jvm.so.1 /usr/lib/librdkafka_jvm.so && \
    ln -s /opt/mapr/lib/librdkafka_jvm.so.1 /usr/lib/librdkafka_jvm.so.1 && \
    ln -s /opt/mapr/lib/librdkafka.so.1 /usr/lib/librdkafka.so && \
    ln -s /opt/mapr/lib/librdkafka.so.1 /usr/lib/librdkafka.so.1 && \
    ln -s /opt/mapr/lib/libMapRClient_c.so.1 /usr/lib/libMapRClient_c.so.1 && \
    ln -s /opt/mapr/lib/libMapRClient_c.so.1 /usr/lib/libMapRClient_c.so  && \
    ln -s /opt/mapr/lib/libMapRClient.so.1 /usr/lib/libMapRClient.so.1 && \
    ln -s /opt/mapr/lib/libMapRClient.so.1 /usr/lib/libMapRClient.so  && \
    ln -s /opt/mapr/include/librdkafka /usr/include/librdkafka

RUN pip install python-snappy python-lzo brotli kazoo requests pytest && pip install --global-option=build_ext $MAPR_STREAMS_PYTHON

ADD ./ldap.conf /etc/ldap.conf

RUN DEBIAN_FRONTEND=noninteractive pam-auth-update && sed -i "s/compat/compat ldap/g" /etc/nsswitch.conf && /etc/init.d/nscd restart

RUN mkdir -p /app/run

COPY gorun.sh /app/run/

RUN chmod +x /app/run/gorun.sh

CMD ["/app/run/gorun.sh"]


