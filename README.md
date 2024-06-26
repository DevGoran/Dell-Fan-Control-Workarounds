# Dell Fan Control Workarounds

## Introduction
The systems default fan behavior for 3rd party PCI cards is assuming the highest thermal load and therefore increases the fan speed significantly. Information reagrding this is scattered around the web and needs some time to be found and understood. This guide should help you solving the issue in a much faster and safer way. There are 2 ways to deal with this:
| # | Workaround | $${\color{green}PROS}$$ | $${\color{red}CONS}$$ |
|---|------------|------|------|
| 1 | Disable 3rd party card behaviour | You do not have to use any scripts or similar. The system will still hanlde the fans dynamically. | Undocumented feature and therefore not supported by Dell. This may damage your system. The fans may still spin at  higher rpms (let's say 35% instead of 20%). |
| 2 | Use a fan speed control script   | You can set the fan speeds yourself with the script and therefore can have a quieter system than with the dynamic fan control. | Undocumented feature and therefore not supported by Dell. This may damage your system. You have to make sure to use the proper values in the script, otherwise your system may overheat. You're dependent on not just the script, but also the cron job.     |



 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

## Disclaimers
> [!NOTE]
> Tested on Dell T630 with 2 fans, BIOS version 2.19.0 and iDrac version FW 2.86.86.86. Commands seem to work but no long-term study on the effects done, yet.

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
> We will be using the following credentials in every command and script: root and calvin for credentials and 0000000000000000000000000000000000000000 for encryption key. Demo IP will be 192.168.168.168. Make sure to use the right values and credentials for your system.

 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

## Workaround 1: Disabling the default fan behaviour
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

## Workaround 2: How to use the fan speed script
Before using the script, check which sensors are available on your system: 
```
ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 sdr type temperature
```
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
6) Create a cron job to run the script. Example cron job:
<pre>*/1 * * * * /bin/bash /root/fancontrol/setspeed.sh > /dev/null 2>&1 
</pre>
> [!CAUTION]
> Please keep in mind that depending on your system you may have to adjust the frequency of the job to update the fans faster. A too low value will eventually lead to overheating.

> [!TIP]
> Keep " ipmitool -I lanplus -H 192.168.168.168 -U root -P calvin -y 0000000000000000000000000000000000000000 raw 0x30 0x30 0x01 0x01" ready. In case the script doesn't work properly you can quickly revert back to the original dynamic fan control. You will have to disable (comment out or delete) the cron job before the command though, otherwise the script will overwrite your command everytime it runs again.

> [!TIP]
> Not necessary to make it work, but when using the script, make sure to make it only readable by root or whoever the owner would be, as the script will contain the credentials of your IPMI user! You want to minimize possible exposure of your credentials.


 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;


## User Reports for specific server models
If you would like to share your experience and results, please follow these steps:
1) Check whether there is a discussion titled "Dell $insert server model$ Fan Control Report"
2) If there is already a discussion, feel free to contribute your experence in the one that already exists. If there is no discussion available yet, please create a new one called "Dell $insert server model$ Fan Control Report" with at least the following information:
   - Your setup: Server model, BIOS and iDrac FW version, components (amount of fans, HDD's, CPU(s), GPU(s) and RAM).
   - Which method you have used to deal with the fan speed.
   - How well it worked.
   - For how long you tested the methods (please test minimum one week with different workloads)


You will also find a script called fancontrolstats, which will save following values to a csv: timestamp of execution, cpu utilization, fan speeds and temparatures. You can set up a cron job and then after a while check the values or even create a graph with it. Make sure to adjust the credentials in the script.


 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;

 &nbsp; 
  &nbsp; &nbsp;
   &nbsp;


## Sources worth mentioning
- https://community.spiceworks.com/t/dell-poweredge-server-r7xx-series-fan-speed-with-gpu/350434/44
- https://github.com/Jono-Moss/R710-IPMI-Fan-Speed-Script/tree/main
- https://www.youtube.com/watch?v=3yJYq0PEhTw
- https://www.dell.com/community/en/conversations/poweredge-hardware-general/t130-fan-speed-algorithm/647f6905f4ccf8a8de60910d
