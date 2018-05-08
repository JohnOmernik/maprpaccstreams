#!/usr/bin/python3
import confluent_kafka
from confluent_kafka import Producer, KafkaError, version, libversion
import json
import time
import os
import sys
import random

#MAPR_STREAMS_VOLUME_LOCATION="/data/prod/teststream"
#MAPR_STREAMS_STREAM_LOCATION="/data/prod/teststream/mystream"
#MAPR_STREAMS_DEFAULT_PARTITIONS=3
#MAPR_STREAMS_TOPIC="testing"

def main():
    print("Confluent Kafka Version: %s - Libversion: %s" % (version(), libversion()))
    topic = os.environ ["MAPR_STREAMS_STREAM_LOCATION"].replace('"', '') + ":" + os.environ["MAPR_STREAMS_TOPIC"].replace('"', '')
    print("Producing messages to: %s" % topic)
    p = Producer({'bootstrap.servers': ''})

# Listen for messages
    running = True
    lastflush = 0
    while running:
        curtime = int(time.time())
        curts = time.strftime("%m/%d/%Y %H:%M:%S")
        message = {}
        message['ts'] = curts
        message['field1'] = "This is fun"
        message['field2'] = "or is it?"
        message_json = json.dumps(message)
        print(message_json)

        try:
            p.produce(topic, value=message_json, callback=delivery_callback)
            p.poll(0)
        except BufferError as e:
            print("Buffer full, waiting for free space on the queue")
            p.poll(10)
            p.produce(topic, value=message_json, callback=delivery_callback)

        except KeyboardInterrupt:
            print("\n\nExiting per User Request")
            p.close()
            sys.exit(0)
        delay = random.randint(1,9)
        print("Sleeping for %s" % delay)
        time.sleep(delay)


def delivery_callback(err, msg):
    """ Called once for each message produced to indicate delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))

if __name__ == "__main__":
    main()
