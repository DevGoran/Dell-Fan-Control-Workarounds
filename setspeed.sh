#!/bin/bash

# IPMI IP address. Adjust value for your system.
IPMIHOST=192.168.168.168
# IPMI Username. root is the default iDrac user. Adjust value for your system.
IPMIUSER=root
# IPMI Password. calvin is the default iDrac password. Adjust value for your system.
IPMIPW=calvin
# Your IPMI Encryption Key. 40x 0's are the default encryption key value. Adjust value for your system.
IPMIEK=0000000000000000000000000000000000000000
# Fan Speeds / utilisation in percentage. Adjust value for your system.
FANSPEED1=20
FANSPEED2=35
FANSPEED3=45
# Temperature thresholds in Celsius. Adjust value for your system.
TEMP1=40
TEMP2=50
TEMP3=60
# Temparature sensor to monitor. Leave the quotation and only replace value inbetween if neccesairy. Adjust value for your system.
SENSOR='Temp'

# This variable sends an IPMI command to get the temperature and outputs it as two digits. The value 'Temp' in this case is the CPU temparature. See README.md for more details.
# Side note, if you are running ipmitool on the system you are controlling, you don't need to specify -H,-U,-P - from the OS installed on the host, ipmitool is assumed permitted. You only need host/user/pass for remote access. 
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type temperature | grep $SENSOR | grep degrees | grep -Po '\d{2}' | tail -1)

# Convert fan speeds to hex
SPEEDHEX1=$( printf "%x" $FANSPEED1 )
SPEEDHEX2=$( printf "%x" $FANSPEED2 )
SPEEDHEX3=$( printf "%x" $FANSPEED3 )

# Check whether $TEMP is equal or greater than $TEMP# and set fan speed based on temperature. Additionally, add info to log file.
if [[ $TEMP -ge $TEMP3 ]]; then
  printf "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)\n" | systemd-cat -t T630-IPMI-TEMP
  echo "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)"
  # Set fans to auto mode
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01
elif [[ $TEMP -ge $TEMP2 ]]; then
  printf "Temperature is high ($TEMP C), setting fan speed to $FANSPEED3%%\n" | systemd-cat -t T630-IPMI-TEMP
  echo "Temperature is high ($TEMP C), setting fan speed to $FANSPEED3%%"
  # Set fans to manual mode and then  apply speed 3.
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x$SPEEDHEX3
elif [[ $TEMP -ge $TEMP1 ]]; then
  printf "Temperature is moderate ($TEMP C), setting fan speed to $FANSPEED2%%\n" | systemd-cat -t T630-IPMI-TEMP
  echo "Temperature is moderate ($TEMP C), setting fan speed to $FANSPEED2%%"
  # Set fans to manual mode and then apply speed 2.
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x$SPEEDHEX2
else
  printf "Temperature is low ($TEMP C), setting fan speed to $FANSPEED1%%\n" | systemd-cat -t T630-IPMI-TEMP
  echo "Temperature is low ($TEMP C), setting fan speed to $FANSPEED1%%"
  # Set fans to manual mode and then apply speed 1.
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
  ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x$SPEEDHEX1
fi
