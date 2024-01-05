# jan/06/2022 09:52:43 by RouterOS 6.49.1
# software id =
#
#
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=192.168.23.2/24 interface=ether1 network=192.168.23.0
/ip dhcp-client
add disabled=no interface=ether2
/ip firewall mangle
add action=mark-packet chain=prerouting connection-state="" dst-port=1195 in-interface=ether1 new-packet-mark=INBOUNDPACKET \
    passthrough=yes protocol=tcp src-address=!192.168.23.0/24
add action=mark-connection chain=prerouting connection-state=new log=yes log-prefix=MARKER new-connection-mark=INBOUND packet-mark=\
    INBOUNDPACKET passthrough=yes
add action=mark-routing chain=prerouting connection-mark=INBOUND log=yes log-prefix=MARKROUTE new-routing-mark=NAT passthrough=yes
add action=mark-routing chain=output connection-mark=INBOUND new-routing-mark=NAT passthrough=yes
add action=log chain=output dst-address=!192.168.23.0/24 log-prefix=OUTPUT
/ip firewall nat
add action=dst-nat chain=dstnat disabled=yes dst-port=1195 in-interface=ether1 log=yes log-prefix=NAT protocol=tcp to-ports=80
add action=masquerade chain=srcnat out-interface=ether2
/ip route
add distance=1 gateway=192.168.23.1 routing-mark=NAT
/ip route rule
add action=lookup-only-in-table routing-mark=NAT table=NAT
/ip service
set ssh port=1195
/tool sniffer
set filter-ip-address=!192.168.23.129/32 filter-stream=yes streaming-enabled=yes streaming-server=192.168.23.129
