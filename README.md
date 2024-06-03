# Dell-T630-IPMI-Fan-Control-Script
Based on https://github.com/Jono-Moss/R710-IPMI-Fan-Speed-Script/tree/main | https://www.youtube.com/watch?v=3yJYq0PEhTw

Difference to the original version: Adapted for Dell T630 with 2 fans and added additional fan levels.

Tested on BIOS version 2.19.0 and iDrac version FW 2.86.86.86.

## How to use
1) In order to be using the following commands or script on debian based systems, install ipmitool (make sure to append sudo if not logged in as root): sudo apt-get update && sudo apt-get install ipmitool
2) Copy the script and make it an executable file.
3) Create a cron job to run at least every minute.\
   Example cron job: */1 * * * * /bin/bash /root/fancontrol/setspeed.sh > /dev/null 2>&1
   
> [!TIP]
> Not neccesairy to make it work, but when using the script, make sure to make it only readable by root or whoever the owner would be, as the script will contain the credentials of your IPMI user! 

Before using the script, check whether you have the same sensors: ipmitool -I lanplus -H iDracIP -U iDracUser -P iDracPW -y iDracEncryptionKey sdr type temperature
You will see something like the following:
<pre>
Inlet Temp       | 04h | ok  |  7.1 | 25 degrees C
Temp             | 0Eh | ok  |  3.1 | 31 degrees C
Temp             | 0Fh | ok  |  3.2 | 31 degrees C
</pre>
In this case, the Inlet Temp is the System Board Inlet Temp and the two Temp values are the 2 CPU package temparatures.


> [!CAUTION]
> Use script on your own risk, no guarantee this will work as excpected. Always test before leaving your system unattended with the script running!
