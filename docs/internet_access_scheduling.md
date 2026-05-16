# Internet Access Scheduling

The Internet Access Scheduling system allows you to define recurring time windows during which specific devices are blocked from accessing the internet. This is ideal for managing screen time, securing devices at night, or automating network policies.

## Key Features

- **Intuitive Heatmap**: A 7-day, 24-hour visual grid to easily "paint" your blocking windows.
- **Drag-to-Select**: Click and drag across the heatmap to quickly create schedules covering multiple days and hours.
- **Manual Override Precedence**: Manual blocks always take priority over schedules. If you manually block a device, it will stay blocked even after a scheduled window ends.
- **Real-time Status Polling**: The UI automatically updates to reflect status changes applied by the background scheduler.
- **Automatic Enforcement**: The background worker applies firewall rules every 5 seconds to ensure immediate compliance with your schedules.

---

## How it Works

The scheduling system operates through a coordination between the **Backend Scheduler**, the **Database**, and your **OpenWRT Router**.

### 1. Defining a Schedule
Schedules are stored in the `device_block_schedules` table. Each entry defines a `start_time`, `end_time`, and a list of `days` (0-6, where 0 is Monday).

### 2. The Background Scheduler
Every 5 seconds, the background worker:
- Retrieves all enabled schedules for all devices.
- Compares the current local time against the defined windows.
- Identifies if a device *should* be blocked or allowed.
- Detects **transitions** (e.g., a schedule just started or just ended).

### 3. Enforcement (OpenWRT)
When a transition is detected, the scheduler communicates with the OpenWRT router via its JSON-RPC API:
- **Blocking**: Adds a `DROP` rule to the top of the firewall and flushes active connections (via `conntrack`).
- **Unblocking**: Removes the specific firewall rule.

### 4. Manual Overrides
To prevent automated schedules from accidentally granting access when you want a device restricted:
- **Manual Block**: Sets `is_manual_block = True` in the database.
- **Precedence**: When a scheduled window ends, the scheduler checks the `is_manual_block` flag. If it is `True`, the **unblock command is skipped**.

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
- **Delete**: Click the Trash icon to permanently remove a schedule.

---

## Troubleshooting

### Schedule Not Applying
- **Time Sync**: Ensure both the IPLoom server and your OpenWRT router have synchronized time (NTP).
- **Integration Status**: Check the **Integrations** page to ensure the OpenWRT connection is healthy.
- **Permissions**: Ensure the router user has `uci` and `conntrack` execution permissions (see [OpenWrt Integration](./openwrt_integration.md)).

### Device Still Has Internet During Block
- Standard firewall rules only block *new* connections.
- Ensure `conntrack` is installed on your router and correctly configured in the ACLs. IPLoom uses it to "kill" existing video streams or downloads the moment a block starts.
