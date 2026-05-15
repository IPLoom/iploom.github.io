# OpenWRT Integration Guide

Integrate your OpenWRT router with IPLoom to automatically sync device lists (DHCP leases) and track real-time data consumption.

## How it Works

IPLoom uses a **"Pull" model**, connecting to your router via its JSON-RPC API (`ubus`/`luci-rpc`) every 15 minutes (configurable).

**Features:**
- **Traffic Monitoring**: Tracks Download/Upload usage per device (requires `nlbwmon`) for **all** devices, including Static IPs.
- **Lease Tracking**: Shows when a device's IP lease will expire.
- **Static IP Support**: Automatically correlates traffic data for devices with Static IPs by looking them up in the local database.
- **Scanner Priority**: Respects the network scanner's authority. Does **not** modify device status, name, or last seen dates, and does **not** create new devices that haven't been discovered by the scanner.

---

## 1. Router Setup (OpenWRT)

### Step 1: Install Dependencies
To enable extensive monitoring, you need to install `nlbwmon` and file capabilities.

1. SSH into your router:
   ```bash
   ssh root@192.168.1.1
   ```

2. Install packages:
   ```bash
   opkg update
   opkg install nlbwmon luci-app-nlbwmon rpcd-mod-file
   
   # Enable nlbwmon
   /etc/init.d/nlbwmon enable
   /etc/init.d/nlbwmon start
   ```

### Step 2: Configure Permissions (ACL)
By default, the router blocks `exec` commands for remote JSON-RPC sessions. To enable **Real-time Traffic Tracking** and **Immediate Device Blocking**, you must allow specific system commands to run.

1.  **Edit the base ACL file:**
    ```bash
    vi /usr/share/rpcd/acl.d/luci-base.json
    ```

2.  **Locate the "file" section:**
    It looks like this:
    ```json
    "file": {
        "/": [ "list" ],
        "/*": [ "list" ]
    },
    ```

3.  **Add the execution permissions:**
    Ensure your `file` section includes the following execution paths:
    ```json
    "file": {
        "/": [ "list" ],
        "/*": [ "list" ],
        "/usr/sbin/nlbw": [ "exec" ],
        "/sbin/uci": [ "exec" ],
        "/bin/sh": [ "exec" ],
        "/etc/init.d/firewall": [ "exec" ],
        "/usr/sbin/conntrack": [ "exec" ]
    },
    ```
    *(Note: Ensure there are commas at the end of each line to maintain valid JSON syntax)*

4.  **Restart the RPC Daemon:**
    ```bash
    /etc/init.d/rpcd restart
    ```

This grants the integration permission to run:
- `/usr/sbin/nlbw`: For bandwidth tracking.
- `/sbin/uci`: For prioritizing firewall rules.
- `/bin/sh`: For executing system scripts.
- `/etc/init.d/firewall`: For reloading the firewall.
- `/usr/sbin/conntrack`: For killing active data streams when a device is blocked.

---

## 2. IPLoom Configuration

1. Go to **Settings** in IPLoom.
2. Scroll to the **OpenWRT Integration** section.
3. Enter your details:
   - **Router URL**: e.g., `http://192.168.1.1`
   - **Username**: `root` (or your custom user)
   - **Password**: Your router password.
   - **Interval**: Polling frequency in minutes (Default: 15).
4. Click **Test**. If successful, click **Save**.
5. You can trigger an immediate sync using the **Sync Now** button.

---

## Technical Deep Dive: Traffic & Lease Logic

The OpenWRT integration handles high-frequency network state data and ensures it remains consistent even if the router restarts.

### 1. Cumulative vs. Delta Traffic
OpenWRT's `nlbwmon` returns **cumulative** counters (total bytes since the service started). To provide useful "usage per interval" stats, IPLoom performs the following:
- **State Tracking**: Stores the `previous_total` for every MAC address in `data/openwrt_stats.json`.
- **Delta Calculation**: `Current Usage = Current_Total - Previous_Total`.
- **History Logging**: These deltas are stored in the `device_traffic_history` table, enabling the sparklines and traffic charts in the UI.

### 2. Counter Reset Handling (Router Reboots)
If the router is rebooted or `nlbwmon` is restarted, the cumulative counters reset to zero. 
- **Detection**: If `Current_Total` is less than `Previous_Total`, IPLoom detects a reset.
- **Logic**: Instead of logging a negative number or a massive spike, it treats the `Current_Total` as the actual delta for that period. This ensures your graphs remain clean and accurate after a power cycle.

### 3. Device Correlation
To ensure traffic is attributed to the correct device, IPLoom uses a multi-layered matching strategy:
1. **MAC Address (Primary)**: Traffic is tracked by MAC address at the router level.
2. **IP Matching**: DHCP leases are pulled to match MACs to current IPs.
3. **Internal ID**: The MAC/IP pair is looked up in the IPLoom `devices` table. If the device was already discovered by the **Network Scanner**, the traffic data is linked to its unique ID.

### 4. Pull Model vs. Real-time
Unlike the Network Scanner (which uses ARP/ICMP), the OpenWRT integration is a **passive observer**. It doesn't ping devices; it simply asks the router "what have you seen lately?" This makes it extremely lightweight and invisible to the network.

---

## Troubleshooting

-   **Connection Failed**: Ensure `uhttpd` is running on the router and not blocked by firewall rules limiting access to LAN only.
-   **No Traffic Data**: Verify `nlbwmon` is running (`ps | grep nlbwmon`) and has gathered data (`ubus call nlbwmon dump`).
-   **Blocked Devices Still Have Internet**: If a device remains connected after being blocked, it is likely that existing data streams were not killed. Ensure the `/usr/sbin/conntrack` permission is correctly added to `luci-base.json` and that the router has the `conntrack` binary available.
-   **Missing Devices**: Ensure the device has been discovered by the IPLoom Network Scanner first. The OpenWRT integration ignores unknown devices to prevent database clutter.
