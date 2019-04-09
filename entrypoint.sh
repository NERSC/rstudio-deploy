#!/bin/bash -l

#source `dirname $0`/setup.sh

#service nslcd restart
echo "Starting services"
nslcd
#nginx
if [ -z $DEBUG ] ; then
  /usr/lib/rstudio-server/bin/rserver  --server-daemonize=0
else
  /usr/lib/rstudio-server/bin/rserver
  bash -l
fi
#service rstudio-server restart
#service httpd restart

#echo "Starting shell"
#/bin/bash -l
#if [ ! "$STARTSHELL" == "" ]
#then  /bin/bash
#else sleep infinity
#fi
