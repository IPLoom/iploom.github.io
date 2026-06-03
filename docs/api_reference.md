# API Reference

The IPLoom Backend provides a standard REST API (v1) for management and monitoring. By default, the API is accessible at `http://{host}:8000/api/v1`.

## Documentation (Swagger)

A live, interactive Swagger UI is available at:
`http://{host}:8000/docs`

## Core Endpoints

### Devices
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/devices` | List all discovered devices. |
| `GET` | `/devices/{id}` | Get detailed metadata for a specific device. |
| `PATCH` | `/devices/{id}` | Update device settings (display name, trust status). |
| `DELETE` | `/devices/{id}` | Remove a device from the inventory. |
| `PATCH` | `/devices/{id}/status` | Manually block/unblock a device (is_manual_block). |

### Discovery & Scans
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/scans` | List historical scan logs. |
| `POST` | `/scans/trigger` | Manually initiate a new full database network scan. |
| `GET` | `/scans/{id}` | Get results of a specific scan. |
| `POST` | `/discovery/scan` | Trigger a high-speed subnet discovery scan (returns list). |
| `GET`/`POST` | `/discovery/scan/stream` | Stream subnet discovery scans in real-time as devices are found. |

### Classification Rules
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/classification/rules` | List all classification rules. |
| `POST` | `/classification/rules` | Create a new custom rule. |
| `PUT` | `/classification/rules/{id}` | Update an existing rule. |

### Custom Brand & Device Assets
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/assets` | List uploaded custom assets (brand logos or device icons). |
| `POST` | `/assets/upload` | Upload new logo or icon asset (multipart Form-data). |
| `DELETE` | `/assets/{id}` | Remove custom asset from server storage and database. |

### Integrations
- **OpenWrt**: `/integrations/openwrt` (Sync, Test Connection, Block/Unblock device)
- **AdGuard**:
  - `/integrations/adguard/config`: Config operations
  - `/integrations/adguard/rules` (`POST`): Add, block, or remove AdGuard custom filtering rules dynamically
- **TP-Link Deco**:
  - `/integrations/deco/config` (`GET`/`POST`): Read or save Deco gateway connection credentials
  - `/integrations/deco/verify` (`POST`): Validate administrator login handshake with Deco primary node
  - `/integrations/deco/sync` (`POST`): Trigger background satellite and client topology synchronization
  - `/integrations/deco/nodes` (`GET`): List all discovered mesh network access points and satellites
- **Tailscale**:
  - `/integrations/tailscale/config` (`GET`/`POST`): Read or save API key configuration and sync intervals
  - `/integrations/tailscale/verify` (`POST`): Verify Tailscale API key permissions
  - `/integrations/tailscale/sync` (`POST`): Run immediate background synchronization of vpn nodes
  - `/integrations/tailscale/devices` (`GET`): List all imported Tailscale VPN overlay nodes
  - `/integrations/tailscale/devices/{id}` (`PATCH`/`DELETE`): Modify VPN node trust status or remove the node
- **MQTT**: `/mqtt/status` (Broker configuration status)

### Analytics & Monitoring
- **DNS Logs**: `GET /analytics/dns/logs` (Retrieve paginated real-time DNS lookup queries for all devices)
- **Device DNS Logs**: `GET /analytics/dns/logs/{device_id}` (Retrieve DNS logs for a specific device)
- **DNS Stats**: `/analytics/dns/stats` (Global DNS block rates and statistics)
- **Topology**: `GET /topology` (Retrieve physical node-link graph data representing gateways, mesh APs, and endpoints)
- **System Logs**: `GET`/`DELETE` `/logs` (Retrieve paginated/filtered system activity logs or clear log history)
- **Task Events**: `GET /task-events` (Poll chronological progress reports and status levels of running background workers)

### SSH Terminal
- **WebSocket Shell**: `/ssh/ws/{ip}` (`WebSocket`): Direct, interactive terminal proxy connection to remote machines.

### Notifications
- **List Notifications**: `GET /notifications` (Fetch recent notifications log with limit and read filters)
- **Unread Count**: `GET /notifications/unread-count` (Get count of unread alert notifications)
- **Mark Read**: `POST /notifications/mark-read` (Mark specific alerts or all alerts as read)
- **Real-time Notifications**: `/notifications/ws` (`WebSocket`): Stream notification events to clients in real-time.

### Internet Quotas
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/internet-quotas/devices/{id}` | Get quota configuration for a device. |
| `POST` | `/internet-quotas/devices/{id}` | Set or update a data quota policy. |
| `DELETE` | `/internet-quotas/devices/{id}` | Remove a quota policy. |
| `POST` | `/internet-quotas/devices/{id}/reset` | Manually reset current usage to zero. |

### Internet Schedules
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/internet-schedules/devices/{id}/schedules` | List all schedules for a device. |
| `POST` | `/internet-schedules/devices/{id}/schedules` | Create a new recurring block window. |
| `PATCH` | `/internet-schedules/schedules/{id}` | Update or toggle an existing schedule. |
| `DELETE` | `/internet-schedules/schedules/{id}` | Delete a schedule. |

## Authentication

All protected API endpoints require a **Bearer JWT Token** in the `Authorization` header. You can obtain a token by authenticating via the `/auth/login` endpoint.

```bash
Authorization: Bearer <your_jwt_token>
```

## Data Formats

All API requests and responses use **JSON**. Timestamps are returned in **ISO 8601** format (UTC).
