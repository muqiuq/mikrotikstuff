# VLAN-DIFF-APPLY.rsc — Script Requirements

## Overview

This is a **templated MikroTik RouterOS script** rendered by `tiksible` (a tool with a Scriban templating engine see scriban_language.md for MikroTik). It does not apply changes directly — it **generates and prints the RouterOS commands** needed to reconcile the live device state against a desired configuration defined in `hosts.yaml`.

---

## Functional Requirements

### FR-1: VLAN Bridge Entry Reconciliation

For each VLAN defined in `host.params.vlan_configs`:

- **FR-1.1** If the VLAN entry does not exist on the bridge, generate an `/interface bridge vlan add` command including tagged trunk ports and untagged access ports (if any).
- **FR-1.2** If the VLAN entry exists but has wrong tagged ports, generate a `set` command to fix tagged ports.
- **FR-1.3** If the VLAN entry exists but has wrong untagged ports, generate a `set` command to fix untagged ports.
- **FR-1.4** Tagged ports for a VLAN are the full `trunkports` list **plus** any `selective_trunks` entries whose `vlans` list includes that VLAN ID.
- **FR-1.5** Untagged ports are prefixed with `default_prefix` (e.g. `ether`) before comparison and output.
- **FR-1.6** VLANs with an empty `ports` list are trunk-only VLANs with no untagged members.

### FR-2: Access Port (Bridge Port) Reconciliation

For each port number listed under a VLAN's `ports`:

- **FR-2.1** If the bridge port entry does not exist, generate an `/interface bridge port add` command.
- **FR-2.2** If the bridge port entry exists, check `pvid`, `edge`, and `bpdu-guard` settings against the VLAN definition.
- **FR-2.3** If any of those three settings deviate, generate a `set` command to correct all three at once.
- **FR-2.4** Port names are constructed as `default_prefix + port_number` (e.g. `ether23`).

### FR-3: Trunk Port Reconciliation

For each port in `host.params.trunkports` (excluding the `bridge` interface itself):

- **FR-3.1** Trunk ports must have `pvid=1`, `edge=auto`, `bpdu-guard=no`.
- **FR-3.2** If the port does not exist as a bridge port, generate an add command.
- **FR-3.3** If the port exists with wrong settings, generate a set command.

### FR-6: Selective Trunk Port Reconciliation

A selective trunk port carries only a defined subset of VLANs as tagged (rather than all VLANs). It is defined in `host.params.selective_trunks`.

- **FR-6.1** Each selective trunk port must be a member of the bridge with `pvid=1`, `edge=auto`, `bpdu-guard=no` — identical bridge port settings to a full trunk.
- **FR-6.2** If the bridge port entry does not exist, generate an `/interface bridge port add` command.
- **FR-6.3** If the bridge port entry exists with wrong settings, generate a `set` command.
- **FR-6.4** The `tagged` list for each VLAN must include only the selective trunk ports whose `vlans` list contains that VLAN ID (see FR-1.4).
- **FR-6.5** Selective trunk ports are not added to `trunkports` — they are a separate collection, keeping full-trunk and partial-trunk semantics distinct.

### FR-4: Unexpected Port Removal

- **FR-4.1** Iterate all interface numbers from 1 to `number_of_interfaces`.
- **FR-4.2** Any port that is neither listed in any VLAN's `ports` nor in `trunkports` but exists as a bridge port member is considered unexpected.
- **FR-4.3** Generate a `/interface bridge port remove` command for each unexpected port.

### FR-5: Output Format

- **FR-5.1** All generated commands are printed as plain RouterOS CLI strings (`:put "..."`), not executed — the script is read-only/diagnostic.
- **FR-5.2** Each generated command is preceded by a human-readable comment line (e.g. `# Port etherX: Fixing bridge port settings`).
- **FR-5.3** Mismatch counters (`vlanMismatches`, `portMismatches`, `trunkMismatches`, `unexpectedPorts`, `missingVlans`) are maintained and printed in a summary block.
- **FR-5.4** If no issues are found, the summary reports "No changes needed".
- **FR-5.5** The script header prints the device identity, date, and time.

---

## Non-Functional Requirements

### NFR-1: Idempotency
Running the script multiple times must always produce the same output for the same device state — no side effects.

### NFR-2: Read-Only on Device
The script never modifies the device; it only reads state and prints fix commands. Applying changes is a deliberate manual or separate step.

### NFR-3: Template-Driven Configuration
All desired-state data lives in `hosts.yaml` under `params`. The script logic is device-agnostic; only the data changes per device.

### NFR-4: Bridge-Centric Model
The script assumes a single bridge named `bridge` is the central switching fabric. All VLANs and ports operate within this bridge.

---

## Data Model (`hosts.yaml` params)

| Parameter              | Type           | Description                                                   |
|------------------------|----------------|---------------------------------------------------------------|
| `default_prefix`       | string         | Interface name prefix applied to port numbers (e.g. `ether`)  |
| `number_of_interfaces` | integer        | Total number of interfaces to scan for unexpected members     |
| `trunkports`           | string[]       | Interfaces that carry all VLANs tagged (incl. `bridge` itself)|
| `selective_trunks`     | object[]       | Optional. Trunk ports that carry only a subset of VLANs tagged|
| `vlan_configs`         | object[]       | List of VLAN definitions (see below)                          |

**VLAN config object:**

| Field        | Type     | Description                                            |
|--------------|----------|--------------------------------------------------------|
| `id`         | integer  | VLAN ID                                                |
| `ports`      | integer[]| Access port numbers (empty = trunk-only VLAN)          |
| `edge`       | string   | STP edge setting (`yes`, `no`, `auto`)                 |
| `bpdu_guard` | string   | BPDU guard setting (`yes`, `no`)                       |

**Selective trunk object:**

| Field       | Type      | Description                                              |
|-------------|-----------|----------------------------------------------------------|
| `interface` | string    | Full interface name (e.g. `sfp-sfpplus3`)                |
| `vlans`     | integer[] | VLAN IDs this port carries as tagged                     |
