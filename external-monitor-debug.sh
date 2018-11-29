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
