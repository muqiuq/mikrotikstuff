# RouterOS 7.X
#
# model = CCR2004-1G-12S+2XS
/interface bridge
add name=bridge-100
add name=bridge-110
add name=bridge-130
add name=bridge-160
add name=bridge-mgmt
/interface ethernet
set [ find default-name=ether1 ] name=ether1-mgmt
set [ find default-name=sfp28-1 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfp28-1-wan
set [ find default-name=sfp28-2 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full
set [ find default-name=sfp-sfpplus1 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus1
set [ find default-name=sfp-sfpplus2 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus2
set [ find default-name=sfp-sfpplus3 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus3-lte
set [ find default-name=sfp-sfpplus4 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus4
set [ find default-name=sfp-sfpplus5 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus5
set [ find default-name=sfp-sfpplus6 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus6
set [ find default-name=sfp-sfpplus7 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus7
set [ find default-name=sfp-sfpplus8 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus8
set [ find default-name=sfp-sfpplus9 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus9
set [ find default-name=sfp-sfpplus10 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus10
set [ find default-name=sfp-sfpplus11 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full name=sfpplus11
set [ find default-name=sfp-sfpplus12 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full comment=SW1 name=sfpplus12-trunk
/interface wireguard
add comment=Roadwarriors listen-port=13133 mtu=1420 name=wireguard_road private-key="?"
/interface vlan
add interface=sfpplus12-trunk name=sfpplus12-vlan100 vlan-id=100
add interface=sfpplus12-trunk name=sfpplus12-vlan110 vlan-id=110
add interface=sfpplus12-trunk name=sfpplus12-vlan130 vlan-id=130
add interface=sfpplus12-trunk name=sfpplus12-vlan160 vlan-id=160
/interface list
add name=WAN
add name=LAN
add name=VPN
add name=LOOPBACK
/ip pool
add name=dhcp-pool-mgmt ranges=192.168.29.128-192.168.29.254
add name=dhcp-pool-vlan100 ranges=192.168.10.128-192.168.10.254
add name=dhcp-pool-vlan110 ranges=192.168.11.128-192.168.11.200
add name=dhcp-pool-vlan130 ranges=192.168.13.128-192.168.13.254
add name=dhcp-pool-vlan160 ranges=192.168.16.128-192.168.16.254
/ip dhcp-server
add address-pool=dhcp-pool-mgmt interface=bridge-mgmt lease-time=6h name=dhcp-vlan1
add address-pool=dhcp-pool-vlan100 interface=bridge-100 lease-time=6h name=dhcp-vlan100
add address-pool=dhcp-pool-vlan110 interface=bridge-110 lease-time=6h name=dhcp-vlan110
add address-pool=dhcp-pool-vlan130 interface=bridge-130 lease-time=6h name=dhcp-vlan130
add address-pool=dhcp-pool-vlan160 interface=bridge-160 lease-time=6h name=dhcp-vlan160
/interface bridge port
add bridge=bridge-100 interface=sfpplus12-vlan100
add bridge=bridge-130 interface=sfpplus12-vlan130
add bridge=bridge-160 interface=sfpplus12-vlan160
add bridge=bridge-110 interface=sfpplus12-vlan110
add bridge=bridge-mgmt interface=ether1-mgmt
/interface list member
add interface=sfp28-1-wan list=WAN
add interface=bridge-130 list=LAN
add interface=bridge-100 list=LAN
add interface=bridge-mgmt list=LAN
add interface=wireguard_road list=VPN
add interface=bridge-160 list=LAN
add interface=bridge-110 list=LAN
/interface wireguard peers
# REMOVED
/ip address
add address=192.168.29.1/24 comment="Management network" interface=bridge-mgmt network=192.168.29.0
add address=192.168.10.1/24 comment="access Network" interface=bridge-100 network=192.168.10.0
add address=192.168.13.1/24 comment="server network" interface=bridge-130 network=192.168.13.0
add address=192.168.16.1/24 comment="smart home network" interface=bridge-160 network=192.168.16.0
add address=192.168.11.1/24 comment="guest network" interface=bridge-110 network=192.168.11.0
add address=192.168.68.2/24 comment="LTE-WAN (Internet Uplink, MikroTik)" interface=sfpplus3-lte network=192.168.68.0
add address=192.168.27.1/24 interface=wireguard_road network=192.168.27.0
/ip dhcp-client
add interface=sfpplus1
add comment="WAN (Default) B.X.X.X.X" interface=sfp28-1-wan
/ip dhcp-server network
add address=192.168.29.0/24 dns-server=192.168.29.1 gateway=192.168.29.1
add address=192.168.10.0/24 dns-server=192.168.10.1 gateway=192.168.10.1
add address=192.168.11.0/24 dns-server=192.168.11.1 gateway=192.168.11.1
add address=192.168.13.0/24 dns-server=192.168.13.1 gateway=192.168.13.1
add address=192.168.16.0/24 dns-server=192.168.16.1 gateway=192.168.16.1
/ip dns
set allow-remote-requests=yes servers=192.168.13.5
/ip firewall address-list
add address=192.168.0.0/16 list=PrivateSubnets
add address=10.0.0.0/8 list=PrivateSubnets
add address=172.16.0.0/12 list=PrivateSubnets
/ip firewall filter
add action=fasttrack-connection chain=forward comment="forward: allow established, related" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="forward: allow established, related " connection-state=established,related
add action=accept chain=forward comment=Anti-Lockout-Rule in-interface=bridge-mgmt src-address=192.168.29.0/24
add action=jump chain=forward comment="forward: WAN-IN jump" in-interface-list=WAN jump-target=WAN-IN
add action=jump chain=forward comment="forward: VPN-IN jump" in-interface-list=VPN jump-target=VPN-IN
add action=jump chain=forward comment="forward: ACCESS-OUT jump" in-interface=bridge-100 jump-target=ACCESS-OUT src-address=192.168.10.0/24
add action=jump chain=forward comment="forward: SERVER-OUT jump" in-interface=bridge-130 jump-target=SERVER-OUT src-address=192.168.13.0/24
add action=jump chain=forward comment="forward: GUEST-OUT jump" in-interface=bridge-110 jump-target=GUEST-OUT src-address=192.168.11.0/24
add action=jump chain=forward comment="forward: SMARTHOME-OUT jump" in-interface=bridge-160 jump-target=SMARTHOME-OUT src-address=192.168.16.0/24
add action=accept chain=input comment=Anti-Lockout-Rule in-interface=bridge-mgmt src-address=192.168.29.0/24
add action=accept chain=input comment="allow wireguard" dst-port=13131-13141 protocol=udp
add action=drop chain=input comment="WAN trigger block (host that tried port scanning are blocked)" src-address-list=WANPortTriggerBlock
add action=accept chain=input comment="allow SSH - management" dst-port=22 protocol=tcp
add action=drop chain=input comment="block too much ICMP" in-interface-list=WAN limit=!5,5:packet protocol=icmp
add action=accept chain=input comment="allow icmp request" protocol=icmp
add action=drop chain=input comment="default drop from WAN" in-interface-list=WAN
add action=accept chain=DEFAULT-OUT comment="default forward: allow internet" dst-address-list=!PrivateSubnets
add action=drop chain=DEFAULT-OUT comment="default forward: drop"
add action=accept chain=ACCESS-OUT comment="access-out: allow my devices to go anywhere" src-address-list=MysDevices
add action=accept chain=VPN-IN comment="access-out: allow my devices to go anywhere" src-address-list=MysDevices
add action=accept chain=ACCESS-OUT comment="access-out: allow access to special devices" dst-address-list=AllowedInternalExternal
add action=jump chain=ACCESS-OUT comment="access-out: last resort" jump-target=DEFAULT-OUT
add action=accept chain=GUEST-OUT comment="guest-out: allow minecraft" dst-address=192.168.10.137
add action=jump chain=GUEST-OUT comment="guest-out: last resort" jump-target=DEFAULT-OUT
add action=accept chain=SERVER-OUT comment="access-out: allow access to special devices" dst-address-list=AllowedInternalExternal
add action=accept chain=SERVER-OUT comment="server-out: allow nas to access camera" dst-address-list=IPCameras src-address=192.168.13.10
add action=accept chain=SERVER-OUT comment="server-out: python-script camera access" dst-address-list=IPCameras src-address=192.168.13.239
add action=accept chain=SERVER-OUT comment="server-out: napf is allow to *" dst-address-list=NapfIsAllowedTo src-address=192.168.13.239
add action=jump chain=SERVER-OUT comment="server-out: last resort" jump-target=DEFAULT-OUT
add action=accept chain=SMARTHOME-OUT comment="access-out: allow access to special devices" dst-address-list=AllowedInternalExternal
add action=jump chain=SMARTHOME-OUT comment="smarthome-out: last resort" jump-target=DEFAULT-OUT
add action=drop chain=forward comment="forward: default drop"
add action=accept chain=VPN-IN comment="vpn-in: allow internal external" dst-address-list=AllowedInternalExternal src-address-list=VPN-IN-AllowInternalExternal
add action=jump chain=VPN-IN comment="vpn-in: default jump" jump-target=DEFAULT-IN
add action=drop chain=DEFAULT-IN comment="default-in: drop"
add action=drop chain=WAN-IN comment="WAN trigger block (host that tried port scanning are blocked)" src-address-list=WANPortTriggerBlock
add action=accept chain=WAN-IN comment="TV7 forward" dst-address-list=TV7 out-interface=bridge-700
add action=jump chain=WAN-IN comment="wan-in: default jump" jump-target=DEFAULT-IN
/ip firewall mangle
add action=add-src-to-address-list address-list=WANPortTriggerBlock address-list-timeout=12h chain=prerouting comment="WAN Port Scan Protection (21,25,631)" dst-port=21,25,631 in-interface-list=WAN protocol=tcp
/ip firewall nat
add action=masquerade chain=srcnat comment="WAN: default masquerade" out-interface-list=WAN
add action=dst-nat chain=dstnat comment="Webserver (Local Loopback)" dst-address-list="Public IP" dst-port=80 in-interface-list=LAN protocol=tcp to-addresses=192.168.13.80 to-ports=80
add action=dst-nat chain=dstnat comment="HTTPS to haproxy (Local Loopback)" dst-address-list="Public IP" dst-port=443 in-interface-list=LAN protocol=tcp to-addresses=192.168.13.80 to-ports=443
add action=dst-nat chain=dstnat comment="HTTPS to haproxy" dst-port=443 in-interface-list=WAN protocol=tcp to-addresses=192.168.13.80 to-ports=443
add action=dst-nat chain=dstnat comment=Webserver dst-port=80 in-interface-list=WAN protocol=tcp to-addresses=192.168.13.80 to-ports=80
add action=dst-nat chain=dstnat comment="HTTP (8080) to haproxy" dst-port=8080 in-interface-list=WAN protocol=tcp to-addresses=192.168.13.80 to-ports=8080
/ip service
set telnet disabled=yes
set ftp disabled=yes
set ssh port=22
set api disabled=yes
set api-ssl disabled=yes
/ipv6 address
add address=SOMEIPV6ADDR advertise=no interface=sfp28-1-wan
add address=fc00:3131:3131::1 advertise=no interface=wireguard_links
/ipv6 firewall filter
add action=accept chain=input comment=DHCPv6 dst-address=fe80::/16 dst-port=546-547 in-interface-list=WAN protocol=udp src-address=fe80::/16 src-port=546-547
add action=accept chain=forward comment="Accept all established and related" connection-state=established,related
add action=accept chain=forward comment="Allow Haproxy" dst-address=SOMEIPV6ADDR/128 dst-port=80,443,8080 protocol=tcp
add action=accept chain=input comment="Allow icmpv6" protocol=icmpv6
add action=accept chain=input comment="Accept all established and related" connection-state=established,related
add action=drop chain=untrusted comment="Drop all from WAN" in-interface-list=WAN
add action=drop chain=untrusted comment="Drop all Invalid" connection-state=invalid
add action=drop chain=forward comment="Drop all not from LAN" in-interface-list=!LAN
add action=accept chain=untrusted comment="Allow DNS requests to Firewall" dst-port=53 protocol=udp
add action=drop chain=untrusted comment="Drop all"
add action=drop chain=input comment="input: drop all from WAN" in-interface-list=WAN
/system identity
set name=r1
/system note
set show-at-login=no

