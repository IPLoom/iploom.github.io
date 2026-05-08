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

### Scans
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/scans` | List historical scan logs. |
| `POST` | `/scans/trigger` | Manually initiate a new network scan. |
| `GET` | `/scans/{id}` | Get results of a specific scan. |

### Classification Rules
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/classification/rules` | List all classification rules. |
| `POST` | `/classification/rules` | Create a new custom rule. |
| `PUT` | `/classification/rules/{id}` | Update an existing rule. |

### Integrations
- **OpenWrt**: `/integrations/openwrt` (Sync, Test Connection)
- **AdGuard**: `/integrations/adguard` (Stats, Device Mapping)

### System
- **SSH**: `/ssh` (Terminal connection handling)
- **Logs**: `/logs` (Server logs)
- **Task Events**: `/task-events` (Live progress of background tasks)

## Authentication

> [!NOTE]
> Currently, IPLoom is designed for local home network use and does not enforce authentication by default. It is recommended to run it behind a reverse proxy (like Nginx or Traefik) if remote access is required.

## Data Formats

All API requests and responses use **JSON**. Timestamps are returned in **ISO 8601** format (UTC).
