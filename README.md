# MapR PACC Running with Python Streams
----------
This has been updated to use Version 6.1.0 of the PACC. The README for 6.0.1 is at README_601.md and the Dockerfile is at Dockerfile_601

Additionally: I am only using Python3 as of now. While Python2 is in the PACC by default, python and pip is linked to python3 and pip3. 

I've also created simlinks from /opt/mapr/lib/librdkafka* and /opt/mapr/lib/libMapR* to /usr/lib. This helps clean things up at startup of your python script.    

## Instructions
--------------
- Copy env.list.template to env.list and update the file to point to your cluster
- Run mkstream.sh to create the volume and stream for the testing. You will need to ensure that you run this from a node with maprcli installed and with permissions to create volumes and streams as specified in your env.list
- Run build.sh to build the docker container
- Run run.sh
  - Once inside the container, run:
    - cd to your directory and run your python code



## Overall
---------------
This is much cleaner with the 6.1.0 PACC then the 6.0.1 PACC
