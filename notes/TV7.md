# MikroTik Init7 Multicast TV

# Multicast IP ranges
Extracted from the playlist: https://www.init7.net/de/support/faq/TV-andere-Geraete/
```
/ip firewall/address-list/add list=TV7 address=239.77.0.0/22
/ip firewall/address-list/add list=TV7 address=239.77.4.0/24
/ip firewall/address-list/add list=TV7 address=239.77.5.0/24
/ip firewall/address-list/add list=TV7 address=233.50.230.39
/ip firewall/address-list/add list=TV7 address=233.50.230.185
/ip firewall/address-list/add list=TV7 address=233.50.230.128
```

# Configuration

Do not directly replicate this configuration. The statements below are sourced from an existing setup and must be tailored to suit the specific requirements of the system in question:

Enable IGMP Proxy:
```
/routing igmp-proxy interface add alternative-subnets=0.0.0.0/0 interface=sfp28-1-wan upstream=yes
/routing igmp-proxy interface add interface=bridge
```

Allow Multicast Traffic to go trough the firewall:
```
/ip firewall filter add action=accept chain=WAN-IN comment="TV7 forward" dst-address-list=TV7 out-interface=bridge
```

Enable IGMP Snooping on internan LAN:
```
/interface bridge add comment="home lan" igmp-snooping=yes name=bridge
```

# Allow IGMP
```
/ip firewall filter add action=accept chain=input comment="IGMP for TV7" protocol=igmp
```

