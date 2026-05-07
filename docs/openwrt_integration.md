# OpenWRT Integration Guide

Integrate your OpenWRT router with HNMS to automatically sync device lists (DHCP leases) and track real-time data consumption.

## How it Works

HNMS uses a **"Pull" model**, connecting to your router via its JSON-RPC API (`ubus`/`luci-rpc`) every 15 minutes (configurable).

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
By default, the router blocks `exec` commands. You must allow `nlbw` to run.

1.  **Edit the ACL file:**
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

3.  **Add the execution permission:**
    Change it to (add the last line):
    ```json
    "file": {
        "/": [ "list" ],
        "/*": [ "list" ],
        "/usr/sbin/nlbw": [ "exec" ]
    },
    ```
    *(Note: Ensure there are commas at the end of the previous lines)*

4.  **Restart RPC Daemon:**
    ```bash
    /etc/init.d/rpcd restart
    ```

---

## 2. HNMS Configuration

1. Go to **Settings** in HNMS.
2. Scroll to the **OpenWRT Integration** section.
3. Enter your details:
   - **Router URL**: e.g., `http://192.168.1.1`
   - **Username**: `root` (or your custom user)
   - **Password**: Your router password.
   - **Interval**: Polling frequency in minutes (Default: 15).
4. Click **Test**. If successful, click **Save**.
5. You can trigger an immediate sync using the **Sync Now** button.

## Troubleshooting

-   **Connection Failed**: Ensure `uhttpd` is running on the router and not blocked by firewall rules limiting access to LAN only.
-   **No Traffic Data**: Verify `nlbwmon` is running (`ps | grep nlbwmon`) and has gathered data (`ubus call nlbwmon dump`).
-   **Missing Devices**: Ensure the device has been discovered by the HNMS Network Scanner first. The OpenWRT integration ignores unknown devices to prevent database clutter.
