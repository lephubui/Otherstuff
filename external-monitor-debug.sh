#!/bin/bash
 
# Save as /usr/bin/monitors/custom_monitor.bash
# Make executable using chmod 700 custom_monitor.bash
 
# Use a custom shell command to perform a health check of the pool member IP address and port
 
# Log debug to local0.debug (/var/log/ltm)?
# Check if a variable named DEBUG exists from the monitor definition
# This can be set using a monitor variable DEBUG=0 or 1
if [ -n "$DEBUG" ]
then
   if [ $DEBUG -eq 1 ]; then echo "EAV `basename $0`: \$DEBUG: $DEBUG" | logger -p local0.debug; fi
else
   # If the monitor config didn't specify debug, enable/disable it here
   DEBUG=0
   #echo "EAV `basename $0`: \$DEBUG: $DEBUG" | logger -p local0.debug
fi
 
# Remove IPv6/IPv4 compatibility prefix (LTM passes addresses in IPv6 format)
IP=`echo $1 | sed 's/::ffff://'`
 
# Save the port for use in the shell command
PORT=$2
 
# Check if there is a prior instance of the monitor running
pidfile="/var/run/`basename $0`.$IP.$PORT.pid"
if [ -f $pidfile ]
then
   kill -9 `cat $pidfile` > /dev/null 2>&1
   echo "EAV `basename $0`: exceeded monitor interval, needed to kill ${IP}:${PORT} with PID `cat $pidfile`" | logger -p local0.error
fi
 
# Add the current PID to the pidfile
echo "$$" > $pidfile
 
# Debug
if [ $DEBUG -eq 1 ]
then
   ####  Customize the log statement here if you want to log the command run or the output ####
   echo "EAV `basename $0`: Running for ${IP}:${PORT} using custom command" | logger -p local0.debug
fi
 
####  Customize the shell command to run here. ###
# Use $IP and $PORT to specify which host/port to perform the check against
# Modify this portion of the line:
# nc $IP $PORT | grep "my receive string" 
# And leave this portion as is:
# '2>&1 > /dev/null'
# The above code redirects stderr and stdout to nothing to ensure we don't errantly mark the pool member up
 
# Send the request request and check the response
nc $IP $PORT | grep "my receive string" 2>&1 > /dev/null
 
# Check if the command ran successfully
# Note that any standard output will result in the script execution being stopped
# So do any cleanup before echoing to STDOUT
if [ $? -eq 0 ]
then
   rm -f $pidfile
   if [ $DEBUG -eq 1 ]; then echo "EAV `basename $0`: Succeeded for ${IP}:${PORT}" | logger -p local0.debug; fi
   echo "UP"
else
   rm -f $pidfile
   if [ $DEBUG -eq 1 ]; then echo "EAV `basename $0`: Failed for ${IP}:${PORT}" | logger -p local0.debug; fi
fi