# Internet Access Scheduling

The Internet Access Scheduling system allows you to define recurring time windows during which specific devices are blocked from accessing the internet. This is ideal for managing screen time, securing devices at night, or automating network policies.

## Key Features

- **Intuitive Heatmap**: A 7-day, 24-hour visual grid to easily "paint" your blocking windows.
- **Drag-to-Select**: Click and drag across the heatmap to quickly create schedules covering multiple days and hours.
- **Administrator Override**: Administrators can apply a "Highest Priority" unblock to instantly restore access, bypassing all active schedules and quotas.
- **Premium Confirmation System**: Critical actions like deleting schedules or applying overrides are protected by custom premium modals to prevent accidental changes.

---

## How it Works

The scheduling system operates through a coordination between the **Backend Scheduler**, the **Database**, and your **OpenWRT Router**.

### 1. Defining a Schedule
Schedules are stored in the `device_block_schedules` table. Each entry defines a `start_time`, `end_time`, and a list of `days` (0-6, where 0 is Monday).

### 2. The Background Scheduler
Every 60 seconds (periodic check) and instantly on user interaction, the background worker:
- Retrieves all enabled schedules for all devices.
- Compares the current local time against the defined windows.
- Identifies if a device *should* be blocked or allowed.
- Detects **transitions** (e.g., a schedule just started or just ended).

### 3. Enforcement (OpenWRT)
When a transition is detected, the scheduler communicates with the OpenWRT router via its JSON-RPC API:
- **Blocking**: Adds a `DROP` rule to the top of the firewall and flushes active connections (via `conntrack`).
- **Unblocking**: Removes the specific firewall rule.

### 4. Policy Resolver (Priority Matrix)
The system uses a tiered priority resolver to determine the final state. A device is blocked if **(Manual Block OR Scheduled Block OR Quota Exceeded) AND NOT Manual Unblock**.

| State | Priority | Effect |
| :--- | :--- | :--- |
| **Manual Unblock** | 🌟 Highest | Overrides all other restrictions. |
| **Manual Block** | 🔴 High | Permanent restriction until toggled. |
| **Scheduled Block** | 🔵 Normal | Restricts during recurring downtime. |
| **Quota Exceeded** | 🟡 Medium | Restricts until reset period or override. |

---

## Configuration

### Creating a Schedule
1.  Navigate to the **Device Details** page for the target device.
2.  Select the **Access Control** tab.
3.  Click and drag on the **Weekly Access Heatmap** to select a range, or click **Add New Window**.
4.  Give the schedule a name (optional) and verify the times.
5.  Click **Create Schedule**.

### Managing Schedules
- **Enable/Disable**: Use the toggle switch on each schedule card to temporarily pause a schedule without deleting it.
- **Edit**: Click the Pencil icon to adjust the name, time, or days.
- **Delete**: Click the Trash icon to permanently remove a schedule. This action is protected by a **Premium Confirmation Modal** to prevent accidental deletion.

---

## Troubleshooting

### Schedule Not Applying
- **Time Sync**: Ensure both the IPLoom server and your OpenWRT router have synchronized time (NTP).
- **Integration Status**: Check the **Integrations** page to ensure the OpenWRT connection is healthy.
- **Permissions**: Ensure the router user has `uci` and `conntrack` execution permissions (see [OpenWrt Integration](./openwrt_integration.md)).

### Device Still Has Internet During Block
- Standard firewall rules only block *new* connections.
- Ensure `conntrack` is installed on your router and correctly configured in the ACLs. IPLoom uses it to "kill" existing video streams or downloads the moment a block starts.
