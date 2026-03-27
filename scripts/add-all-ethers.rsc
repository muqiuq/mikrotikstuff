# Create bridge
/interface bridge
add name=bridge protocol-mode=rstp

# Add ether1 to ether24 to bridge
:for i from=1 to=24 do={
    /interface bridge port
    add bridge=bridge interface=("ether" . $i)
}