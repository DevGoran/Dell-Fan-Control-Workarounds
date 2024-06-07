# Dell T630 Fan Control

## Introduction
The systems default fan behavior for 3rd party PCI cards is assuming the highest thermal load and therefore increases the fan speed significantly. There are 2 ways to deal with this:
| # | Workaround | $${\color{green}PROS}$$ | $${\color{red}CONS}$$ |
|---|------------|------|------|
| 1 | Disable 3rd party card behaviour | You do not have to use any scripts or similar. The system will still hanlde the fans dynamically. | Undocumented feature and therefore not supported by Dell. This may damage your system. The fans may still spin at  higher rpms (let's say 35% instead of 20%). |
| 2 | Use a fan speed control script   | You can set the fan speeds yourself with the script and therefore can have a quieter system than with the dynamic fan control. | Undocumented feature and therefore not supported by Dell. This may damage your system. You have to make sure to use the proper values in the script, otherwise your system may overheat. You're dependend on not just the script, but also the cron job.     |



 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

## Disclaimers
> [!NOTE]
> Tested on Dell T630 with 2 fans, BIOS version 2.19.0 and iDrac version FW 2.86.86.86.

> [!CAUTION]
> The script has been optimized for my personal setup and should be customized before being used on other systems.

> [!CAUTION]
> Use script or commands on your own risk, no guarantee this will work as excpected.

 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

## Prerequisits
1) iDrac is configured with a static IP.
2) If root is not being used, an additional user needs to be created with the proper priviliges.
3) IPMI over LAN is enabled.
4) IPMI Lan Privilage is set to Admin.
6) On your host ipmitool is installed (apt-get update && apt-get install ipmitool)

> [!NOTE]
> We will be using the following credentials in every command and script: root, calvin and 0000000000000000000000000000000000000000 for encryption key. Demo IP will be 192.168.168.168. Make sure to use the right values and credentials for your system.

 
 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

## How to use the fan speed script
Before using the script, check which sensors are available on your system: 
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
3) Adjsut fan speed and temparture treshold values to your likings (so the system doesn't overheat, but with comfortable fan speeds). Keep in mind that those tresholds might be different in summer and winter time.
4) Adjust the sensor value, which is the temparature sensor value from before. Use the exact name like in the output.
5) Save the script.
6) Create a cron job to run at least every minute. Please keep in mind that depending on your system you may have to adjust that job.\
   Example cron job: */1 * * * * /bin/bash /root/fancontrol/setspeed.sh > /dev/null 2>&1


> [!TIP]
> Keep " ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 raw 0x30 0x30 0x01 0x01" ready. In case the script doesn't work properly you can quickly revert back to the original dynamic fan control.

> [!TIP]
> Not necessary to make it work, but when using the script, make sure to make it only readable by root or whoever the owner would be, as the script will contain the credentials of your IPMI user!

 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

## Disabling the default fan behaviour
Check if the default fan bevaiour is enabled or disabled by using following raw command:
```
ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 raw 0x30 0xce 0x01 0x16 0x05 0x00 0x00 0x00
```

The response will tell you whether it is enabled or disabled.
<pre>
Disabled response: 16 05 00 00 00 05 00 01 00 00
Enabled response:  ﻿16 05 00 00 00 05 00 00 00 00
</pre>

We can then enable or disable this behaviour with follwoing commands:

Disable: 
```
ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x01 0x00 0x00
```
Enable:
```
ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x00 0x00 0x00
```


 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

## Sources
- https://community.spiceworks.com/t/dell-poweredge-server-r7xx-series-fan-speed-with-gpu/350434/44
- https://github.com/Jono-Moss/R710-IPMI-Fan-Speed-Script/tree/main
- https://www.youtube.com/watch?v=3yJYq0PEhTw
- https://www.dell.com/community/en/conversations/poweredge-hardware-general/t130-fan-speed-algorithm/647f6905f4ccf8a8de60910d
