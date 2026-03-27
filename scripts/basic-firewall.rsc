/ip firewall filter
add action=fasttrack-connection chain=forward comment="forward: established, related" connection-state=established,related hw-offload=yes
add action=accept chain=input comment="input: allow established, related" connection-state=established,related
add action=accept chain=input comment="input: allow winbox, ssh" dst-port=8291,22 protocol=tcp
add action=accept chain=input comment="input: allow ping" icmp-options=8:0-255 protocol=icmp
add action=drop chain=input comment="input: default drop"
add action=accept chain=forward comment="forward: established, related" connection-state=established,related
add action=drop chain=forward comment="forward: default drop" connection-nat-state=!dstnat
