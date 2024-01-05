:local DHCPGateway [/ip/dhcp-client/get ether2 gateway]
:foreach i in=[/ip/route/find dst-address=9.9.9.9/32 && static=yes ] do=\
{
:local currentGateway [/ip route get $i gateway]
:if ($currentGateway != $DHCPGateway) do=\
{ 
:log info "DHCP Gateway changed to $DHCPGateway "
/ip route/set $i gateway=$DHCPGateway 
}
}