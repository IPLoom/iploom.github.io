# Database Schema

IPLoom utilizes **DuckDB** for its primary data storage. DuckDB was chosen for its high-performance columnar storage, making it ideal for analytical queries over historical network data while remaining lightweight enough to run on embedded systems.

## Entity Relationship Diagram

```mermaid
erDiagram
    DEVICES ||--o{ SCAN-RESULTS : "found in"
    DEVICES ||--o{ DEVICE-PORTS : "has"
    DEVICES ||--o{ STATUS-HISTORY : "state changes"
    DEVICES ||--o{ TRAFFIC-HISTORY : "usage"
    DEVICES ||--o{ DEVICE-QUOTAS : "enforced by"
    DEVICES ||--o{ DEVICE-BLOCK-SCHEDULES : "governed by"
    
    SCANS ||--o{ SCAN-RESULTS : "contains"
    
    DEVICES {
        string id PK
        string ip
        string mac
        string display_name
        string device_type
        timestamp last_seen
        string vendor
        boolean is_trusted
        boolean is_blocked
        boolean is_manual_block
        boolean is_manual_unblock
        boolean is_quota_exceeded
        boolean is_scheduled_block
    }
    
    DEVICE-QUOTAS {
        string device_id FK
        bigint limit_bytes
        bigint current_usage
        int period_hours
        timestamp last_reset_at
        boolean enabled
    }

    DEVICE-BLOCK-SCHEDULES {
        string id PK
        string device_id FK
        string name
        string start_time
        string end_time
        string days
        boolean enabled
    }

    SCANS {
        string id PK
        string target
        string status
        timestamp started_at
        timestamp finished_at
    }
    
    SCAN-RESULTS {
        string id PK
        string scan_id FK
        string ip
        string mac
        string open_ports
    }
    
    DEVICE-PORTS {
        string device_id FK
        int port
        string service
        timestamp last_seen
    }
    
    STATUS-HISTORY {
        string id PK
        string device_id FK
        string status
        timestamp changed_at
    }
```

## Key Tables

### `devices`
The core inventory of your network. Every unique MAC address discovered is stored here. 
- **Policy Flags**: Tracks the current blocking state across multiple layers:
    - `is_manual_block`: Administrator manual override.
    - `is_manual_unblock`: High-priority administrator unblock (bypasses all other rules).
    - `is_quota_exceeded`: Automatically managed by the Quota service.
    - `is_scheduled_block`: Automatically managed by the Schedule service.

### `device_quotas`
Stores bandwidth consumption policies. Linked 1:1 with devices to enforce data caps over recurring periods.

### `device_block_schedules`
Stores recurring time windows for internet access restriction. Supports 7-day granularity.

### `scans` & `scan_results`
Tracks every network scan performed by the system.
- `scans` stores the metadata (duration, success/failure).
- `scan_results` is a snapshot of exactly what was found at that specific moment in time.

### `device_status_history`
Enables the "Uptime" and "Presence" analytics. Every time a device flips between `online` and `offline`, a new row is added here. This allows the UI to calculate availability percentages over any time range.

### `device_traffic_history`
Stores data consumption metrics gathered from integrations like **OpenWrt**.
- `rx_bytes` / `tx_bytes`: Cumulative data transferred.
- `down_rate` / `up_rate`: Current speed at the time of sync.

## Performance Optimization

IPLoom uses specialized indexes to ensure that historical queries remain fast even after months of data collection:
- `idx_history_device_id`: Fast lookup for specific device uptime.
- `idx_traffic_timestamp`: Optimized for rendering traffic charts over time.
- `idx_scan_results_mac`: Correlation between devices and their scan history.

## Timezone and Timestamp Standard

All temporal columns (such as `last_seen`, `changed_at`, `started_at`, etc.) are standardized across the entire system:
- **Database Storage**: Timestamps are stored in UTC (timezone-naive or timezone-aware matching UTC offsets). DuckDB connections are configured globally with `SET TimeZone='UTC'`.
- **Client Presentation**: Timezone shifting is performed presentationally on the client-side.
  - *Web UI*: ApexCharts graphs disable default UTC formatting (`datetimeUTC: false`) to automatically convert and render timestamps in the user's local browser timezone. Luxon parsed DateTimes are localized using `.toLocal()`.
  - *Mobile App*: Flutter's parsed DateTimes use `.toLocal()` to format and display chart labels and event streams in the device's local timezone.

## Manual Database Access

Since DuckDB is a file-based database, you can inspect it manually using the DuckDB CLI:

```bash
# Inside the container or data directory
duckdb network_scanner.duckdb

# Example Query: Top 5 devices by open port count
SELECT display_name, json_array_length(open_ports) as ports 
FROM devices 
ORDER BY ports DESC 
LIMIT 5;
```

> [!CAUTION]
> Avoid modifying the database while the IPLoom service is running to prevent database locking issues.
