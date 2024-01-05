:local HOST "172.16.252.9"
:local PINGCOUNT "4"

:if ([/ping $HOST interval=1 count=$PINGCOUNT] = 0) do={
:log warn "VPN to ZH is down. Disabling and enabling it"
:delay 1000ms
/interface/wireguard/peers set [ find interface=wireguard-zh ] disabled=yes
:delay 1000ms
/interface/wireguard/peers set [ find interface=wireguard-zh ] disabled=no
} else={
/tool fetch url="HEARTBEAT_URL" keep-result=no
}
