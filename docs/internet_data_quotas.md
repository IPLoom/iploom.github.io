# Internet Data Quotas

The Internet Data Quotas feature allows administrators to set consumption limits for individual devices on the network. When a device exceeds its allocated data within a specific timeframe, it is automatically restricted from accessing the internet.

## Overview

Data quotas work in tandem with the **Internet Access Schedules** and **Manual Blocking** systems. The centralized **Policy Engine** ensures that if any restriction is active (Manual, Scheduled, or Quota), the device remains blocked.

### Key Features
- **Flexible Limits**: Set data limits in Megabytes (MB).
- **Recurring Periods**: Choose from various reset intervals (e.g., 24 hours, Weekly, Monthly).
- **Real-time Tracking**: Consumption is tracked in real-time as the system polls the OpenWRT router for bandwidth metrics.
- **Automated Enforcement**: The background worker automatically applies and lifts restrictions based on usage.
- **Administrator Overrides**: Administrators can apply a "Highest Priority" unblock to instantly restore access, bypassing all active quotas and schedules.

## Configuration

To set a quota for a device:
1. Navigate to the **Device Details** page.
2. Select the **Access Control** tab.
3. Scroll to the **Internet Data Quota** section.
4. Enter the desired **Limit (MB)** and select the **Reset Period**.
5. Toggle the **Enabled** switch and click **Save Quota Policy**.

## How it Works

### 1. Data Collection
The `OpenWRTClient` synchronization service polls the router periodically. It calculates the "delta" (difference) in total bytes transmitted since the last poll and increments the `current_usage` field in the database for that device.

### 2. Policy Evaluation
Every 60 seconds (by default), the background worker runs the `check_and_apply_quotas` task:
- It checks if `current_usage` has exceeded the `limit_bytes`.
- It checks if the `period_hours` has elapsed since the `last_reset_at` timestamp.
- If the period has elapsed, the `current_usage` is reset to 0, and the `last_reset_at` is updated. 
- **Auto-Cleanup**: The system automatically clears the `is_manual_unblock` flag during a reset to ensure policies are re-enforced for the new period.

### 3. Policy Engine Logic (Priority Matrix)
The system uses a tiered priority resolver to determine the final state. A device is blocked if **(Manual Block OR Scheduled Block OR Quota Exceeded) AND NOT Manual Unblock**.

| State | Priority | Effect |
| :--- | :--- | :--- |
| **Manual Unblock** | 🌟 Highest | Overrides all other restrictions. |
| **Manual Block** | 🔴 High | Permanent restriction until toggled. |
| **Quota Exceeded** | 🟡 Medium | Restricts until reset period or override. |
| **Scheduled Block** | 🔵 Normal | Restricts during recurring downtime. |

## Manual Overrides & Stability

### Administrator Unblock Override
If a device is restricted by a quota, a **"Manually Restore Access"** button appears. Applying this override creates a high-priority exception. Because this is a critical action, the UI utilizes a premium **Confirmation Modal** explaining that this bypasses all automated rules.

### Premium Confirmation Modals
To ensure platform stability and a professional UX, all destructive or critical actions (Delete, Reset, Override) use a centralized confirmation system. These modals are **Teleported** to the root of the document to prevent UI clipping and use isolated event handling to prevent accidental closure.

### Usage Reset
The **Reset** button (refresh icon) manually sets the `current_usage` to 0 and clears the `is_quota_exceeded` flag. This is the preferred way to grant more data to a device mid-cycle without applying a total policy bypass.

## Technical Details

### Database Schema
Quotas are stored in the `device_quotas` table:
- `limit_bytes`: The maximum allowed consumption.
- `current_usage`: The total bytes used in the current period.
- `period_hours`: The duration of the quota cycle.
- `last_reset_at`: When the usage was last cleared.
- `is_exceeded`: A cached flag for quick lookup.

### API Endpoints
- `GET /api/v1/internet-quotas/devices/{id}`: Get quota configuration.
- `POST /api/v1/internet-quotas/devices/{id}`: Set/Update quota.
- `DELETE /api/v1/internet-quotas/devices/{id}`: Remove quota.
- `POST /api/v1/internet-quotas/devices/{id}/reset`: Manually reset usage.
