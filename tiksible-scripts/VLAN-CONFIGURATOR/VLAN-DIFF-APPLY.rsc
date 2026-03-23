{{## VLAN Difference Apply Script ##}}
{{## Generates executable MikroTik commands to fix configuration mismatches ##}}

{{func prepend 
ret host.params.default_prefix + $0
end}}

# ============================================================
# VLAN Configuration Fix Commands
# Device: [/system identity get name]
# Generated: [/system clock get date] [/system clock get time]
# ============================================================

:local vlanMismatches 0
:local portMismatches 0
:local trunkMismatches 0
:local unexpectedPorts 0
:local missingVlans 0

{{## Check VLAN Bridge Configuration and generate fixes ##}}
{{ for vlan in host.params.vlan_configs }}
{{ vlan_tagged = host.params.trunkports }}
{{ if host.params.selective_trunks }}
{{ for st in host.params.selective_trunks }}
{{ for vid in st.vlans }}
{{ if vid == vlan.id }}{{ vlan_tagged = vlan_tagged | array.add st.interface }}{{ end }}
{{ end }}
{{ end }}
{{ end }}
:local vlanExists [/interface bridge vlan find bridge=bridge vlan-ids={{ vlan.id }}]
:if ($vlanExists != "") do={
    :local currentTaggedRaw [/interface bridge vlan get $vlanExists tagged]
    :local currentUntaggedRaw [/interface bridge vlan get $vlanExists untagged]
    :local currentTagged [:tostr $currentTaggedRaw]
    :local currentUntagged [:tostr $currentUntaggedRaw]
    :local expectedTagged "{{ vlan_tagged | array.join ";" }}"
    {{ if vlan.ports.size > 0 }}
    :local expectedUntagged "{{ vlan.ports | array.join ";" @prepend }}"
    {{ else }}
    :local expectedUntagged ""
    {{ end }}
    
    :if ($currentTagged != $expectedTagged) do={
        :put "# VLAN {{ vlan.id }}: Fixing tagged ports"
        :put "/interface bridge vlan set [find bridge=bridge vlan-ids={{ vlan.id }}] tagged={{ vlan_tagged | array.join "," }}"
        :set vlanMismatches ($vlanMismatches + 1)
    }
    {{ if vlan.ports.size > 0 }}
    :if ($currentUntagged != $expectedUntagged) do={
        :put "# VLAN {{ vlan.id }}: Fixing untagged ports"
        :put "/interface bridge vlan set [find bridge=bridge vlan-ids={{ vlan.id }}] untagged={{ vlan.ports | array.join "," @prepend }}"
        :set vlanMismatches ($vlanMismatches + 1)
    }
    {{ end }}
} else={
    {{ if vlan.ports.size > 0 }}
    :put "# VLAN {{ vlan.id }}: Adding missing VLAN with ports"
    :put "/interface bridge vlan add bridge=bridge vlan-ids={{ vlan.id }} tagged={{ vlan_tagged | array.join "," }} untagged={{ vlan.ports | array.join "," @prepend }}"
    {{ else }}
    :put "# VLAN {{ vlan.id }}: Adding missing VLAN"
    :put "/interface bridge vlan add bridge=bridge vlan-ids={{ vlan.id }} tagged={{ vlan_tagged | array.join "," }}"
    {{ end }}
    :set missingVlans ($missingVlans + 1)
}

{{ end }}

{{## Check Bridge Port Configuration and generate fixes ##}}
{{ for vlan in host.params.vlan_configs }}
{{ if vlan.ports.size > 0 }}
{{ for i in vlan.ports }}
:local portExists [/interface bridge port find interface={{ host.params.default_prefix }}{{ i }}]
:if ($portExists != "") do={
    :local currentPvid [/interface bridge port get $portExists pvid]
    :local currentEdge [/interface bridge port get $portExists edge]
    :local currentBpdu [/interface bridge port get $portExists bpdu-guard]
    
    :if (($currentPvid != {{ vlan.id }}) || ($currentEdge != "{{ vlan.edge }}") || ($currentBpdu != {{ vlan.bpdu_guard }})) do={
        :put "# Port {{ host.params.default_prefix }}{{ i }}: Fixing bridge port settings"
        :put "/interface bridge port set [find interface={{ host.params.default_prefix }}{{ i }}] pvid={{ vlan.id }} edge={{ vlan.edge }} bpdu-guard={{ vlan.bpdu_guard }}"
        :set portMismatches ($portMismatches + 1)
    }
} else={
    :put "# Port {{ host.params.default_prefix }}{{ i }}: Adding to bridge"
    :put "/interface bridge port add bridge=bridge interface={{ host.params.default_prefix }}{{ i }} pvid={{ vlan.id }} edge={{ vlan.edge }} bpdu-guard={{ vlan.bpdu_guard }}"
    :set portMismatches ($portMismatches + 1)
}

{{ end }}
{{ end }}
{{ end }}

{{## Check Trunk Port Configuration and generate fixes ##}}
{{ for i in host.params.trunkports }}
{{ if i != "bridge" }}
:local portExists [/interface bridge port find interface={{ i }}]
:if ($portExists != "") do={
    :local currentPvid [/interface bridge port get $portExists pvid]
    :local currentEdge [/interface bridge port get $portExists edge]
    :local currentBpdu [/interface bridge port get $portExists bpdu-guard]
    
    :if (($currentPvid != 1) || ($currentEdge != "auto") || ($currentBpdu != false)) do={
        :put "# Trunk {{ i }}: Fixing trunk port settings"
        :put "/interface bridge port set [find interface={{ i }}] pvid=1 edge=auto bpdu-guard=no"
        :set trunkMismatches ($trunkMismatches + 1)
    }
} else={
    :put "# Trunk {{ i }}: Adding to bridge"
    :put "/interface bridge port add bridge=bridge interface={{ i }} pvid=1 edge=auto bpdu-guard=no"
    :set trunkMismatches ($trunkMismatches + 1)
}

{{ end }}
{{ end }}

{{## Check Selective Trunk Port Configuration and generate fixes ##}}
{{ if host.params.selective_trunks }}
{{ for st in host.params.selective_trunks }}
:local portExists [/interface bridge port find interface={{ st.interface }}]
:if ($portExists != "") do={
    :local currentPvid [/interface bridge port get $portExists pvid]
    :local currentEdge [/interface bridge port get $portExists edge]
    :local currentBpdu [/interface bridge port get $portExists bpdu-guard]
    
    :if (($currentPvid != 1) || ($currentEdge != "auto") || ($currentBpdu != false)) do={
        :put "# Selective trunk {{ st.interface }}: Fixing trunk port settings"
        :put "/interface bridge port set [find interface={{ st.interface }}] pvid=1 edge=auto bpdu-guard=no"
        :set trunkMismatches ($trunkMismatches + 1)
    }
} else={
    :put "# Selective trunk {{ st.interface }}: Adding to bridge"
    :put "/interface bridge port add bridge=bridge interface={{ st.interface }} pvid=1 edge=auto bpdu-guard=no"
    :set trunkMismatches ($trunkMismatches + 1)
}

{{ end }}
{{ end }}

{{## Check for unexpected ports and generate removal commands ##}}
{{ configured_ports = [] }}
{{ for vlan in host.params.vlan_configs }}
{{ for port in vlan.ports }}
{{ configured_ports = configured_ports | array.add port }}
{{ end }}
{{ end }}

{{ i = 1 }}
{{ max_interfaces = host.params.number_of_interfaces * 1 }}
{{ while i <= max_interfaces }}
{{ is_configured = false }}
{{ for port in configured_ports }}
{{ if i == port }}
{{ is_configured = true }}
{{ end }}
{{ end }}
{{ is_trunk = false }}
{{ for trunk in host.params.trunkports }}
{{ if trunk == (host.params.default_prefix + i) }}
{{ is_trunk = true }}
{{ end }}
{{ end }}
{{ if !is_configured && !is_trunk }}
:local portExists [/interface bridge port find interface={{ host.params.default_prefix }}{{ i }}]
:if ($portExists != "") do={
    :put "# Port {{ host.params.default_prefix }}{{ i }}: Removing unexpected port"
    :put "/interface bridge port remove [find interface={{ host.params.default_prefix }}{{ i }}]"
    :set unexpectedPorts ($unexpectedPorts + 1)
}
{{ end }}
{{ i = i + 1 }}
{{ end }}

# ============================================================
# Summary
# ============================================================
:local totalIssues ($vlanMismatches + $portMismatches + $trunkMismatches + $unexpectedPorts + $missingVlans)
:put ("# Total fixes generated: " . $totalIssues)
:put ("# - VLAN fixes:          " . $vlanMismatches)
:put ("# - Port fixes:          " . $portMismatches)
:put ("# - Trunk fixes:         " . $trunkMismatches)
:put ("# - Port removals:       " . $unexpectedPorts)
:put ("# - VLANs to add:        " . $missingVlans)
:if ($totalIssues = 0) do={
    :put "# Status: No changes needed - configuration is correct"
} else={
    :put ("# Status: " . $totalIssues . " command(s) generated")
    :put "# "
    :put "# To apply these changes, copy the commands above (excluding comments)"
    :put "# and paste them into the MikroTik terminal or save as a .rsc file"
}
