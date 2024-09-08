### TRACCAR
###Variables####
:global lat
:global lon
:global speed1
:global speed2
:global alt1
:global alt2
:local systemid 1234
:host "host:port"

###GPS####
:put ("[*] Capturing GPS coordinates...")
/system gps monitor once do={
:set $lat $("latitude");
:set $lon $("longitude");
:set $alt1 $("altitude");
:set $speed1 $("speed")
}

:set $alt2 [:pick $alt1 0 [find $alt1 " m"]]
:set $speed2 [:pick $speed1 0 [find $speed1 " km/h"]]

:local message "lat=$lat&lon=$lon&speed=$speed2&altitude=$alt2"

:if (($lat != "none") && ($speed2 > 1)) do={
    :put ("[*] Sending message to Traccar...");
    :log info ("[*] Sending message to Traccar...");
    /tool/fetch keep-result=no url="http://$host/?id=$systemid&$message"
} else={
    :put ("[*] Not sending speed to low or no GPS");
}