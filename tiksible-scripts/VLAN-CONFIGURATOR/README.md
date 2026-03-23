# VLAN-CONFIGURATOR

A [tiksible](https://github.com/muqiuq/tiksible) script template that performs a **dry-run VLAN audit** on a MikroTik switch and prints the exact RouterOS commands needed to bring the device into the desired state — without applying any changes itself.

> **Requires [tiksible](https://github.com/muqiuq/tiksible)**  
> The script (`VLAN-DIFF-APPLY.rsc`) is a Scriban template rendered by tiksible against `hosts.yaml`. It cannot be run directly on the device.

---

## How it works

tiksible connects to the device over SSH, renders the template with the desired-state data from `hosts.yaml`, and executes the resulting RouterOS script. The script reads the live device state and **prints (`:put`) the fix commands** for every mismatch found. No changes are applied automatically — you review the output and apply the printed commands manually.

---

## Features

### VLAN bridge entry reconciliation
- For each VLAN defined in `vlan_configs`, the script checks whether the corresponding `/interface bridge vlan` entry exists with the correct `tagged` and `untagged` port lists.
- Missing VLANs → generates an `add` command.
- Wrong tagged or untagged ports → generates a `set` command.

### Access port reconciliation
- For every port number listed under a VLAN, the script checks the `/interface bridge port` entry for correct `pvid`, `edge`, and `bpdu-guard` settings.
- Missing port → generates an `add` command.
- Wrong settings → generates a `set` command to correct all three at once.

### Trunk port reconciliation
- Ports listed in `trunkports` are validated for `pvid=1`, `edge=auto`, `bpdu-guard=no`.
- Missing or misconfigured trunk ports get the appropriate `add` or `set` command generated.

### Selective trunk port reconciliation
- Ports in `selective_trunks` carry only a defined subset of VLANs as tagged (instead of all VLANs).
- Bridge port settings are enforced identically to full trunk ports (`pvid=1`, `edge=auto`, `bpdu-guard=no`).
- Only the specified VLANs include the selective trunk port in their `tagged` list.

### Unexpected port removal
- Any bridge port member within the `1..number_of_interfaces` range that is not assigned to any VLAN or trunk list is considered unexpected.
- Generates a `/interface bridge port remove` command for each one.

### Summary output
At the end of the run the script prints a breakdown of all detected mismatches:
- VLAN fixes
- Port fixes
- Trunk fixes
- Ports to remove
- VLANs to add

If everything matches, it reports **"No changes needed"**.

---

## Configuration (`hosts.yaml`)

| Parameter | Description |
|---|---|
| `default_prefix` | Interface name prefix, e.g. `ether` |
| `number_of_interfaces` | Total number of interfaces to scan for unexpected ports |
| `trunkports` | List of full trunk ports (including `bridge` itself) |
| `selective_trunks` | List of `{interface, vlans[]}` for partial-trunk ports |
| `vlan_configs` | List of `{id, ports[], edge, bpdu_guard}` VLAN definitions |

### Example

```yaml
hosts:
  - name: SW-CORE
    address: 192.168.1.1
    credentialsAlias: SW-CORE
    params:
      default_prefix: ether
      number_of_interfaces: 24
      trunkports: ["bridge", "sfp-sfpplus1"]
      selective_trunks:
        - interface: sfp-sfpplus2
          vlans: [10, 20]
      vlan_configs:
        - id: 10
          ports: [1, 2, 3]
          edge: yes
          bpdu_guard: yes
        - id: 20
          ports: [4, 5]
          edge: yes
          bpdu_guard: yes
```

---

## Usage

1. Configure `hosts.yaml` with your device details and desired VLAN layout.
2. Run tiksible pointing at this template:
   ```
   tiksible apply VLAN-DIFF-APPLY.rsc --write
   ```
3. Review the printed RouterOS commands.
4. Copy and paste the commands into the MikroTik terminal (or save as a `.rsc` file and import) to apply the changes.

---

## Design principles

- **Read-only on device** — the script never modifies anything; it only reads state and prints fix commands.
- **Idempotent** — running it multiple times always produces the same output for the same device state.
- **Template-driven** — all desired-state data lives in `hosts.yaml`; the script logic is device-agnostic.
- **Bridge-centric** — assumes a single bridge named `bridge` as the central switching fabric.
