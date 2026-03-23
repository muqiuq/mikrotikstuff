# ============================================================
# add_all_ports.rsc
# Adds all ethernet interfaces to a bridge.
# Adjust the variables below before running.
# ============================================================

# --- Configuration ---

# Name of the target bridge
:local bridgeName   "bridge"

# Mark ports as edge (yes/no)
# Edge ports skip STP listening/learning phases (use for access ports)
:local setEdge      "yes"

# Enable BPDU guard (yes/no)
# Requires edge=yes - disables the port if a BPDU frame is received
:local setBpduGuard "yes"

# Only add interfaces whose name starts with this prefix (e.g. "ether", "sfp")
# Leave empty "" to add all ethernet interfaces
:local portPrefix   "ether"

# ============================================================

# Helper: log + print to console
:local logput do={
    :log info $1
    :put $1
}

:if ([:len [/interface bridge find name=$bridgeName]] = 0) do={
    $logput ("add_all_ports: bridge \"" . $bridgeName . "\" not found - creating it.")
    /interface bridge add name=$bridgeName
    $logput ("add_all_ports: bridge \"" . $bridgeName . "\" created.")
}

$logput ("add_all_ports: starting | bridge=" . $bridgeName \
    . " edge=" . $setEdge . " bpdu-guard=" . $setBpduGuard)

:local added   0
:local skipped 0

:foreach iface in=[/interface ethernet find] do={
    :local ifName [/interface ethernet get $iface name]

    :if ($portPrefix != "" && [:find $ifName $portPrefix] != 0) do={
        :log debug ("add_all_ports: skipping " . $ifName . " - does not match prefix \"" . $portPrefix . "\"")
    } else={
        :if ([:len [/interface bridge port find bridge=$bridgeName interface=$ifName]] > 0) do={
            $logput ("add_all_ports: skipping " . $ifName . " - already member of " . $bridgeName)
            :set skipped ($skipped + 1)
        } else={
            /interface bridge port add \
                bridge=$bridgeName      \
                interface=$ifName       \
                edge=$setEdge           \
                bpdu-guard=$setBpduGuard
            $logput ("add_all_ports: added " . $ifName . " to " . $bridgeName)
            :set added ($added + 1)
        }
    }
}

:local summary ("add_all_ports: done | added=" . $added . " skipped=" . $skipped)
$logput $summary
