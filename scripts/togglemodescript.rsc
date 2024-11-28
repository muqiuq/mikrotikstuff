:local toggleNatRule do={
    :local action ($1);
    :foreach ruleId in=[/ip firewall nat find chain=srcnat action=masquerade] do={
        :if ([/ip firewall nat get $ruleId out-interface] = "ether1") do={
            :if ($action = "enable") do={
                /ip firewall nat enable $ruleId;
            } else={
                /ip firewall nat disable $ruleId;
            }
        }
    }
};

:local ledStatus [/system leds get [find leds=user-led] type];
:if ($ledStatus = "off") do={
    /interface bridge port disable [find interface=ether1];
    /ip dhcp-client enable [find interface=ether1];
   $toggleNatRule "enable";
    /system leds set [find leds=user-led] type=on;
   :log info "Enabled uplink mode"
} else={
    /ip dhcp-client disable [find interface=ether1];
    $toggleNatRule "disable";
    /interface bridge port enable [find interface=ether1];
    /system leds set [find leds=user-led]  type=off;
   :log info "Disabled uplink mode"
}
