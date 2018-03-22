#!/bin/bash

#groupmod -g 1020 rundeck
find /etc/rundeck -group rundeck -exec chgrp -h 1020 {} \;
find /var/rundeck -group rundeck -exec chgrp -h 1020 {} \;
find /var/lib/rundeck -group rundeck -exec chgrp -h 1020 {} \;
groupmod -g 1020 rundeck

#usermod -u 1020 rundeck
find /etc/rundeck -user rundeck -exec chown -h 1020 {} \;
find /var/rundeck -user rundeck -exec chown -h 1020 {} \;
find /var/lib/rundeck -user rundeck -exec chown -h 1020 {} \;
usermod -u 1020 rundeck

#Set rundeck hostname 
rundeck_hostname=`hostname -f`
sed -i "s/RUNDECK_HOSTNAME/${rundeck_hostname}/g" /etc/rundeck/framework.properties
sed -i "s/RUNDECK_HOSTNAME/${rundeck_hostname}/g" /etc/rundeck/rundeck-config.properties

# Start Rundeck
function logging
{
    m_time=`date "+%F %T"`
    echo $m_time" "$1
}

/etc/init.d/rundeckd start
status=$?
if [ $status -ne 0 ]; then
  logging "Failed to start Rundeck Server : $status"
  exit $status
fi

# Naive check runs every  15 sec  to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container will exit with an error
# if it detects that either of the processes has exited.
# Otherwise it will loop forever, waking up every 15 seconds
  
while /bin/true; do
  ps aux | grep rundeck | grep -q -v grep
  CHECK_1_STATUS=$?
  pgrep -F /var/run/rundeckd.pid | grep -q -v grep
  CHECK_2_STATUS=$?
  # If the greps above find anything, they will exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $CHECK_1_STATUS -ne 0 -o $CHECK_2_STATUS -ne 0 ]; then
    logging "Rundeck failed or died unexpectedly ."
    exit -1
  else
    logging "Rundeck server running with pid $(cat /var/run/rundeckd.pid)"
  fi   
  sleep 15
done
