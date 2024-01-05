:local PingTarget1 9.9.9.9
:local PingTarget2 9.9.9.9

:local FailTreshold 3

:global PingFailCountISP1

:if ([:typeof $PingFailCountISP1] = "nothing") do={:set PingFailCountISP1 0}

:log debug ("gateway ping check script (Failcount: " . $PingFailCountISP1 . ")")

:local PingResult
:local PingResult1
:local PingResult2

:set PingResult1 [ping $PingTarget1 count=1]
:set PingResult2 [ping $PingTarget2 count=1]
:set $PingResult ($PingResult1 + $PingResult2)

:log debug ("ping result is " . $PingResult)

:if ($PingResult = 0) do={
 :if ($PingFailCountISP1 < ($FailTreshold+2)) do={
  :set PingFailCountISP1 ($PingFailCountISP1 + 1)
  :if ($PingFailCountISP1 = $FailTreshold) do={
   :log warning "ether2 uplink has a problem en route to $PingTarget1 - increasing distance of routes."
   :foreach i in=[/ip/route/find dst-address=0.0.0.0/0 && static=yes ] do=\
    {
    /ip/route set $i distance=1
    }
   :log warning "Route distance increase finished."
  }
 }
}

:if ($PingResult > 0) do={
 :if ($PingFailCountISP1 > 0) do={
  :set PingFailCountISP1 ($PingFailCountISP1 - 1)
  :if ($PingFailCountISP1 = ($FailTreshold -1)) do={
   :log warning "ether2 can reach $PingTarget1 again - bringing back original distance of routes."
   :foreach i in=[/ip/route/find dst-address=0.0.0.0/0 && static=yes ] do=\
    {
    /ip/route set $i distance=3
    }
   :log warning "Route distance decrease finished."
  }
 }
}

:if ($PingResult = 2) do={
 /tool fetch url="HEARTBEAT_URL" keep-result=no
}