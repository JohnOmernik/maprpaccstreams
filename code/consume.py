#!/usr/bin/python3

from confluent_kafka import Consumer, KafkaError
import json
import time
import os
import sys
import random

#MAPR_STREAMS_VOLUME_LOCATION="/data/prod/teststream"
#MAPR_STREAMS_STREAM_LOCATION="/data/prod/teststream/mystream"
#MAPR_STREAMS_DEFAULT_PARTITIONS=3
#MAPR_STREAMS_TOPIC="testing"

topic = os.environ["MAPR_STREAMS_STREAM_LOCATION"].replace('"', '') + ":" + os.environ["MAPR_STREAMS_TOPIC"].replace('"', '')

c = Consumer({'bootstrap.servers': "", 'group.id': "mytestconsumer1", 'default.topic.config': {'auto.offset.reset': "earliest"}})
c.subscribe([topic])
print("Subscribing to %s" % topic)
# Listen for messages
running = True
while running:
    curtime = int(time.time())
    try:
        message = c.poll(timeout=5)
        if message is not None: 
            print(message.value())
        else:
            print("Timeout reached, trying again")
    except KeyboardInterrupt:
        print("\n\nExiting per User Request")
        c.close()
        sys.exit(0)

