#!/bin/bash

docker run --privileged --name=rundeck --hostname=`hostname -f` -d -t -i -p 4440:4440 kadamonkar/rundeck-docker:latest 
