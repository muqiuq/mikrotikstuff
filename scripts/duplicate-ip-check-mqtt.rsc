# Define arrays for bridge interfaces and address ranges
:local vlannames [:toarray "vlan1,vlan2,vlan3"]
:local bridgeArray [:toarray "bridge-vlan1,bridge-vlan2,bridge-vlan3"]
:local addressArray [:toarray "192.168.1.0/24,192.168.2.0/24,192.168.3.0/24"]

# Loop through each bridge and address range pair
:for idx from=0 to=([:len $bridgeArray] - 1) do={
    :local bridge [:pick $bridgeArray $idx]
    :local vlanname [:pick $vlannames $idx]
    :local addressRange [:pick $addressArray $idx]
    :put "START $bridge"
    # Initialize variables for each iteration
    :local ipList ""
    :local ipArray [:toarray ""]
    :local macArray [:toarray ""]
    
    # Perform IP scan for the current bridge and address range
    :foreach entry in=[/tool ip-scan interface=$bridge duration=30s address-range=$addressRange as-value] do={
        :local ip ($entry->"address")
        :local mac ($entry->"mac-address")
        :set $found false
        :for i from=0 to=([:len $ipArray] - 1) do={
            :if ([:pick $ipArray $i] = $ip) do={
                :if ([:pick $macArray $i] != $mac) do={
                    :set $ipList ($ipList . $ip . " ")
                    :set $found true
                }
            }
        }
        :if ($found = false) do={
            :set ($ipArray->[:len $ipArray]) $ip
            :set ($macArray->[:len $macArray]) $mac
        }
    }
    
    # Publish results to MQTT
    :put $ipList
    /iot mqtt publish broker=MQTTBROKER1 topic=("mikrotik/duplicate-ips/" . $vlanname) message=" $ipList"
}
