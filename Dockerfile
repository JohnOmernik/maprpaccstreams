FROM maprtech/pacc:6.1.0_6.0.0_ubuntu16

# Install a bunch of tools for compiling Only doing Python3 now

ENV MAPR_STREAMS_PYTHON="http://package.mapr.com/releases/MEP/MEP-6.0.0/mac/mapr-streams-python-0.11.0.tar.gz"


RUN apt-get update && apt-get install -y \
              nano vim \
              git \
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

#pip install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" $MAPR_STREAMS_PYTHON


CMD ["/bin/bash"]


