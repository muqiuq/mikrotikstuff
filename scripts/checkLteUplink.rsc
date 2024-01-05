:local PingTarget1 9.9.9.9
:local PingTarget2 9.9.9.9

:local FailTreshold 3

:global PingFailCountISP1

:if ([:typeof $PingFailCountISP1] = "nothing") do={:set PingFailCountISP1 0}

:log debug ("uplink ping check script (Failcount: " . $PingFailCountISP1 . ")")

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
   :log warning "lte uplink has a problem en route to $PingTarget1 - disable and enable lte1"
   /interface/lte/set lte1 disabled=yes
   :delay 5
   /interface/lte/set lte1 disabled=no
  }
 }
}

:if ($PingResult > 0) do={
 :if ($PingFailCountISP1 > 0) do={
  :set PingFailCountISP1 ($PingFailCountISP1 - 1)
  :if ($PingFailCountISP1 = ($FailTreshold -1)) do={
   :log warning "lte1 can reach $PingTarget1 again"
  }
 }
}

