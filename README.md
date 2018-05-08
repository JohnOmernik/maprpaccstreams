# MapR PACC Running with Python Streams
----------
Due to challenges with the 6.0.1 PACC, I've put together this as a way to document how to get things working, and the challenges. 



## Instructions
--------------
- Copy env.list.template to env.list and update the file to point to your cluster
- Run mkstream.sh to create the volume and stream for the testing. You will need to ensure that you run this from a node with maprcli installed and with permissions to create volumes and streams as specified in your env.list
- Run build.sh to build the docker container
- Run run.sh
  - Once inside the container, run:
    -  cd /app/code
    - export LD_LIBRARY_PATH=/opt/mapr/lib # Have to do this to find the right library - It should stick from Docker file, see below. 
    - LD_PRELOAD=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so ./produce.py # You must use the LD_PRELOAD this is the producer script
    - LD_PRELOAD=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so ./consume.py # This is the consumer script
    


### Challenge 1: No librdkafka in the Container
----------
The PACC does not come with librdkafka. You would think it would be easy to just download a .deb (I am using Ubuntu) however, because the librdkafka package relies on the full mapr-client, it will not install with dpkg

This problem is fixable (as you can see in the Docker file).  It should be either included, or easier to install in the PACC. You can see the two ENV lines and the one RUN line I added to download the .deb and manually unpack it into the right places. 

### Challenge 2: LD_LIBRARY_PATH
----------
The one is odd for me. To install I followed the install for librdkafka

https://maprdocs.mapr.com/home/MapR_Streams/MapRStreamCAPISetup.html

and then I followed (for the Python client) 

https://maprdocs.mapr.com/home/AdvancedInstallation/InstallingStreamsPYClient.html#task_fc1_ssg_3z 

Now, a few things. I am running the PACC 6.0.1 on a MapR 6.0.1 cluster. The instructions say no need to add the jvm location to LD_LIBRARY_PATH

So, when I try to run my produce.py script after starting the PACC with run.sh, it fails with

cd /app/code

./produce.py

ImportError: librdkafka.so.1: cannot open shared object file: No such file or directory

Why is this? In my Dockerfile I am adding the LD_LIBRARY_PATH... env|grep LD_LIBRARY_PATH  ... oh. 

So, even though I set the LD_LIBRARY_PATH it's not passing that to my env.  

If I add

export LD_LIBRARY_PATH=/opt/mapr/lib

Then I get 

ImportError: /opt/mapr/lib/libMapRClient_c.so: undefined symbol: JNI_GetCreatedJavaVMs


That's better, and related to libjvm.so, so I try to add the libjvm.so location back in

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server 

and I stil get:

ImportError: /opt/mapr/lib/libMapRClient_c.so: undefined symbol: JNI_GetCreatedJavaVMs

The only way I can get it to run is:

LD_PRELOAD=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so ./produce.py 

Thus, at a minimum, documentation seems pretty far off, and ideally, this stuff should just be handled in the PACC to make the developer experience better. 

### Challenge 3: Doc Confusion
-----------
In the docs for python client

https://maprdocs.mapr.com/home/AdvancedInstallation/InstallingStreamsPYClient.html#task_fc1_ssg_3z

It has MEP-3.0 hard coded in the line. This could get confusing if folks don't know they need to change it. (<version> is a variable, why not MEP?)

Also, is there an option for "universal"? In the Package directory? installing from under "mac" even when for linux seems like another avenue for confusion. 


### Bonus Challenge related to LD_LIBRARY_PATH
------------
Why doesn't WORKDIR /app/code work in the PACC? 


