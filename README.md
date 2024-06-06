# Dell T630 IPMI Fan Control Script
> [!NOTE]
> Tested on Dell T630 with 2 fans, BIOS version 2.19.0 and iDrac version FW 2.86.86.86.

> [!CAUTION]
> This script has been optimized for my personal setup and should be customized before being used on other systems.

> [!CAUTION]
> Use script on your own risk, no guarantee this will work as excpected. Always test before leaving your system unattended with the script running!

## Why you may need this
If you would like to use PCI cards, which are not "designed or qualified" by Dell, and want your fan speeds to get lower than 75% speed. For some reason Dell has decided to pin the speed at this minimum once certain conditions are met (example: unmatched GPU). They claim that many of these "unqualified" cards do not have active thermal sensor monitoring or standard sensor reading topologies and claim that due to that they are not able to fine tune the fans for such cards.

## Prerequisits
1) iDrac is configured with a static IP.
2) If root is not being used, an additional user needs to be created with the properr priviliges.
3) IPMI over LAN is enabled.
4) IPMI Lan Privilage is set to Admin.
5) Serial over LAN is enabled.
6) On your host ipmitool is installed (apt-get update && apt-get install ipmitool)

## How to use
Before using the script, check which sensors are available on your system (make sure to replace IP, credentials and encryption key): 
<pre>ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 sdr type temperature</pre>
You will see something similar to the following output. In this case, the Inlet Temp is the System Board Inlet Temp and the two Temp values are the 2 CPU package temparatures:
<pre>
Inlet Temp       | 04h | ok  |  7.1 | 25 degrees C
Temp             | 0Eh | ok  |  3.1 | 31 degrees C
Temp             | 0Fh | ok  |  3.2 | 31 degrees C
</pre>
The sensor choice is important, as otherwise you may monitor the wrong value and your system overheats or still will have its fans be spinning at high rpms. Make sure to figure out which sensor is for what. Note down the sensor name, as you will need it later.

1) Save the script in a folder and make it an executable file.
2) Fill out user, password, host address and encryption key values.
3) Adjsut fan speed and temparture treshold values to your likings (so the system doesn't overheat, but with comfortable fan speeds). Keep in mind that those tresholds might be different in summer than winter time.
4) Adjust the sensor value, which is the temparature sensor value from before. Use the exact name like in the output.
5) Save the script.
6) Create a cron job to run at least every minute. Please keep in mind that depending on your system you may have to adjust that job.\
   Example cron job: */1 * * * * /bin/bash /root/fancontrol/setspeed.sh > /dev/null 2>&1


> [!TIP]
> Keep " ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 raw 0x30 0x30 0x01 0x01" ready (with your credentials instead of the demo ones here). In case the script doesn't work properly you can quickly revert back to the original dynamic fan control.

> [!TIP]
> Not neccesairy to make it work, but when using the script, make sure to make it only readable by root or whoever the owner would be, as the script will contain the credentials of your IPMI user!


## Sources
- https://community.spiceworks.com/t/dell-poweredge-server-r7xx-series-fan-speed-with-gpu/350434/44
- https://github.com/Jono-Moss/R710-IPMI-Fan-Speed-Script/tree/main
- https://www.youtube.com/watch?v=3yJYq0PEhTw
