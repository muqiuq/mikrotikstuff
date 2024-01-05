:local HOST "192.168.65.1"

:local PINGCOUNT "4"


:if ([/ping $HOST interval=1 count=$PINGCOUNT] = 0) do={

:log warn "VPN to ZH is down. Disabling and enabling it"

:delay 1000ms

/interface/wireguard/peers set [ find interface=wireguard_h62 ] disabled=yes
:delay 1000ms
/interface/wireguard/peers set [ find interface=wireguard_h62 ] disabled=no

} else={

/tool fetch url="HEARTBEAT URL" keep-result=no

}