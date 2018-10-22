FROM maprtech/pacc:6.0.1_5.0.0_ubuntu16

# Versions being run
ENV MAPR_LIBRDKAFKA_BASE="http://package.mapr.com/releases/MEP/MEP-5.0/ubuntu"
ENV MAPR_LIBRDKAFKA_FILE="mapr-librdkafka_0.11.3.201803231414_all.deb"

# A Shotgun approach to setting all the potential variabls to ensure MapR librdkafka gets used in the Confluent Python install
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV LIBRARY_PATH=/opt/mapr/lib
ENV C_INCLUDE_PATH=/opt/mapr/include
# MapR 6.0.1 per the docs
ENV LD_LIBRARY_PATH=/opt/mapr/lib
# Mapr 6.0.0 and earlier
#ENV LD_LIBRARY_PATH=/opt/mapr/lib:$JAVA_HOME/jre/lib/amd64/server


# Install a bunch of tools fo compiling
RUN apt-get update && apt-get install -y \
              nano \
              vim \
              git \
              python python-dev python-setuptools python-pip python3 python3-dev python3-setuptools python3-pip build-essential \
              zlib1g-dev libssl-dev libsasl2-dev liblz4-dev libsnappy1v5 libsnappy-dev liblzo2-2 liblzo2-dev \
              python-docutils \
         && rm -rf /var/lib/apt/lists/*

# Install MapR LibRD KAfka - Have to unpack it and manually install it into the PACC
RUN MYPWD=`pwd` && wget ${MAPR_LIBRDKAFKA_BASE}/${MAPR_LIBRDKAFKA_FILE} && dpkg -x ${MAPR_LIBRDKAFKA_FILE} ./tmp  && \
    mkdir /opt/mapr/include/librdkafka && cp ./tmp/opt//mapr/include/librdkafka/* /opt/mapr/include/librdkafka/ && \
    cp ./tmp/opt/mapr/lib/librdkafka.so.1 /opt/mapr/lib/ &&  cd /opt/mapr/lib && ln -s librdkafka.so.1 librdkafka.so && ln -s librdkafka.so.1 librdkafka.a &&  ln -s libMapRClient.so libMapRClient_c.so && cd $MYPWD && \
    rm -rf ./tmp && rm ./${MAPR_LIBRDKAFKA_FILE} && ldconfig

RUN pip install python-snappy python-lzo brotli kazoo requests pytest
RUN pip3 install python-snappy python-lzo brotli kazoo requests pytest

# This is still showing the Java and MapR Directories set above
RUN echo "$LD_LIBRARY_PATH"


##### Use one of the two methods to install confluent_kafka package for Python

# MapR Python Installation Method from https://maprdocs.mapr.com/home/AdvancedInstallation/InstallingStreamsPYClient.html#task_fc1_ssg_3z

ENV MAPR_STREAMS_PYTHON="http://archive.mapr.com/releases/MEP/MEP-5.0/mac/mapr-streams-python-0.11.0.tar.gz"
RUN pip install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" $MAPR_STREAMS_PYTHON
RUN pip3 install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" $MAPR_STREAMS_PYTHON

# This also works  - Getting the confluent-kafka package directly from github

#RUN git clone https://github.com/confluentinc/confluent-kafka-python && cd confluent-kafka-python && \
#    LD_LIBRARY_PATH=$LD_LIBRARY_PATH LIBRARY_PATH=/opt/mapr/lib C_INCLUDE_PATH=/opt/mapr/include python setup.py install && \
#    LD_LIBRARY_PATH=$LD_LIBRARY_PATH LIBRARY_PATH=/opt/mapr/lib C_INCLUDE_PATH=/opt/mapr/include python3 setup.py install && \
#    cd ..

#####


# This is STILL Showing the LD_LIBRARY_PATH however, it goes away once you run
RUN echo "$LD_LIBRARY_PATH"

# This has no effect on the MapR PACC
WORKDIR /app/code
