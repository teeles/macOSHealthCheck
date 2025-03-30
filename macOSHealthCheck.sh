#!/bin/bash

###############################################
#  V1.0 - 02/11/23
#  Thomas Eeles. 
#  macOS Health Check (M.H.C)
#  Script for helpdesk and end users to track details of their device. 
#  The scipt lets users see if there macBook is ready to be replaced. 
#    - To Do: Add logging to /var/logs, add in function for Button Two, cheange the variables about, add in checks for SwiftDialog.       
###############################################

#Variables One
sysprofile=$(system_profiler SPSoftwareDataType)
serial_number="$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')"
hostname="$(hostname)"
macOS=$(sw_vers -productVersion)
product_name=$(/usr/libexec/PlistBuddy -c 'print 0:product-name' /dev/stdin <<< "$(/usr/sbin/ioreg -ar -k product-name)")
year=$(echo "$product_name" | grep -oE '\b[0-9]{4}\b')

#Functions

bat_cycle_count() {
	local CycleCount=$(system_profiler SPPowerDataType | grep -E "Cycle Count" | awk '{print $3}')

	if [ "$CycleCount" -gt 800 ]; then
    	echo "Performing action Z (Cycle Count > 800)"
	elif [ "$CycleCount" -gt 600 ]; then
    	echo "Performing action Y (Cycle Count > 600)"
	elif [ "$CycleCount" -gt 300 ]; then
    	echo "Performing action X (Cycle Count > 300)"
	else
    	echo "Cycle Count is within normal range: $CycleCount"
fi
}

bat_max_capacity() {
	local MaxCap=$(system_profiler SPPowerDataType | grep -E "Maximum Capacity" | awk '{print $3}' | tr -d '%')

if [ "$MaxCap" -lt 50 ]; then
    echo "Performing action Z (Maximum Capacity < 50%)"
elif [ "$MaxCap" -lt 75 ]; then
    echo "Performing action Y (Maximum Capacity < 75%)"
elif [ "$MaxCap" -lt 90 ]; then
    echo "Performing action X (Maximum Capacity < 90%)"
else
    echo "Battery health is good (Maximum Capacity >= 90%): $MaxCap%"
fi
}

bat_condition() {
	local condition=$(system_profiler SPPowerDataType | grep -E "Condition" | awk '{print $2}')

	if [[ "$condition" == "Normal" ]]; then
    echo "Battery condition is Normal."
elif [[ "$condition" == "Service" ]]; then
    echo "Battery condition is Service recommended!"
else
    echo "Unknown battery condition: $condition"
fi
}

macage() {
    
    local current_year=$(date +%Y)
    local age=$((current_year - year))

    if (( age > 2 )); then
        echo "$hostname is over 3 years old and could be replaced"
    else
        echo "Device Build Year: $year <br> Device Age: $age Years"
    fi
}


#Few more varibales
batteryCycle=$(bat_cycle_count)
batteryMaxCapacity=$(bat_max_capacity)
batcondition=$(bat_condition)
macold=$(macage)

#Final bosss
overall_status() {

    local current_year=$(date +%Y)
    local mac_age=$((current_year - year))

    # Determine overall status
    if [[ "$batcondition" == *"Service recommended"* ]] || [[ "$batteryMaxCapacity" == *"< 50%"* ]]; then
        echo "The device has failed one or more checks and needs attention"
    elif (( mac_age > 2 )); then
        echo "The device is too old for reuse, but can be donated"
    else
        echo "Put back into circulation"
    fi
}



status=$(overall_status)

# Build the dialog box

  /usr/local/bin/dialog \
  --title "MacBook Health Service" \
  --icon "" \
  --message "Overall Status: $status <br> Serial Number: $serial_number <br> Hostname: $hostname <br> macOS: $macOS <bR> $batcondition <br> $batteryMaxCapacity <br> $batteryCycle <br> $macold" \
  --button2 \
  --button2text "Generate Log File"

  case $? in
  0)
  echo "Pressed OK"
  # Button 1 processing here
  ;;
  2)
  echo "Pressed button two (button 2)"
  jamf policy -trigger 
  ;;
  3)
  echo "Pressed Info Button (button 3)"
  # Button 3 processing here
  ;;
  4)
  echo "Timer Expired"
  # Timer ran out code here
  ;;
  5)
  echo "quit: command used"
  # post quit: command code here
  ;;
  10)
  echo "User quit with cmd+q"
  # User quit code here
  ;;
  30)
  echo "Key Authorisation Failed"
  # Key auth failure code here
  ;;
  201)
  echo "Image resource not found"
  ;;
  202)
  echo "Image for icon not found"
  ;;
  *)
  echo "Something else happened"
  ;;
esac
