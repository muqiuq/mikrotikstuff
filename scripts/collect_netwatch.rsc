:local isup [:len [/tool/netwatch/find where status=up]]
:local isdown [:len [/tool/netwatch/find where status=down]]
:local total ($isup + $isdown)
:local status ("UP%3A%20" . $isup . "%20DOWN%3A%20" . $isdown . "%20TOTAL%3A%20" . $total)

/tool fetch url="HEARTBEAT_URL/$status" keep-result=no 
