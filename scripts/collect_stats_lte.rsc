:local monitor [/interface/lte/monitor lte1 once as-value]
:local rxtx ("%20RX%20" . [/interface/get lte1 rx-byte] . "%20TX%20" . [/interface/get lte1 tx-byte])
:local sendstr ("RSSI%20" . ($monitor->"rssi") . "%20CELLID%20" . ($monitor->"current-cellid") . $rxtx)

:local fullurl ("HEARTBEAT_URL" . $sendstr)

/tool/fetch url=$fullurl keep-result=no


