### TRACCAR
:global lat
:global lon
:global speed1
:global speed2
:global alt1
:global alt2
:global zeroSpeedCount
:local systemid "1234"
:local host "host:port"
:local noMovementTransmitThreshold 60

### Check and Initialize zeroSpeedCount
:if ([:len $zeroSpeedCount] = 0) do={
  :set $zeroSpeedCount 0;
  :put ("[*] Initialized global variable zeroSpeedCount")
}

### GPS ####
:put ("[*] Capturing GPS coordinates...")
/system gps monitor once do={
  :set $lat $("latitude");
  :set $lon $("longitude");
  :set $alt1 $("altitude");
  :set $speed1 $("speed")
}

:set $alt2 [:pick $alt1 0 [find $alt1 " m"]]
:set $speed2 [:pick $speed1 0 [find $speed1 " km/h"]]

:set $speed2 [:tonum $speed2 ]

### Modify speed if below 0.5 km/h
:if ($speed2 < 0.5) do={
  :set $speed2 0;
}

:local message "lat=$lat&lon=$lon&speed=$speed2&altitude=$alt2"

### Check if speed is zero and manage zeroSpeedCount
:if ($speed2 = 0) do={
  :set $zeroSpeedCount ($zeroSpeedCount + 1);
  :put ("[*] To slow increasing counter to $zeroSpeedCount")
}

### Send the message based on conditions
:if (($lat != "none") && ($speed2 != 0 || $zeroSpeedCount >= $noMovementTransmitThreshold)) do={
  /tool/fetch keep-result=no url="http://$host/?id=$systemid&$message"
  :put ("[*] Transmitting GPS location $message")
  :log info ("[*] Transmitting GPS location $message")
  :set $zeroSpeedCount 0;  # Reset counter after sending message
}
