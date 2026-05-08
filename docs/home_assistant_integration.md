# Home Assistant Integration Guide

HNMS integrates natively with Home Assistant via **MQTT Discovery**, automatically registering every device on your network as a trackable entity — no manual YAML configuration required.

![Home Assistant Discovery](../.img/HA%20Dsicovery.png)

---

## How it Works

When a device is discovered (or its status changes), HNMS publishes two things to your MQTT broker:

1. **A Discovery Config payload** — tells Home Assistant to create a `device_tracker` entity automatically.
2. **A State + Attributes payload** — provides the current online/offline status and rich metadata.

Home Assistant's MQTT integration picks these up instantly via its standard discovery mechanism.

---

## Prerequisites

- MQTT must be **enabled and connected** in HNMS Settings. See the [MQTT Integration Guide](./mqtt_integration.md).
- Home Assistant must have the **MQTT Integration** installed and connected to the same broker.
- In Home Assistant: `Settings → Devices & Services → MQTT` — ensure it is configured and listening.

---

## 1. Enable in HNMS

1. Go to **Settings** in HNMS.
2. Scroll to the **MQTT Configuration** section.
3. Fill in your broker details and ensure the connection status is **green (Online)**.
4. Enable **Home Assistant Discovery** if there is a dedicated toggle (or it activates automatically when MQTT is online).

Discovery payloads are published automatically every time a device comes **online**.

---

## 2. MQTT Topic Structure

All topics use the configured **Base Topic** (default: `network_scanner`). Each device is identified by a unique ID derived from its MAC address:

```
unique_id = hnms_{mac_without_colons_lowercase}
# Example: MAC 00:11:22:AA:BB:CC → hnms_001122aabbcc
```

### Topic Map

| Topic | Direction | Description |
|---|---|---|
| `homeassistant/device_tracker/{unique_id}/config` | HNMS → HA | Discovery config — creates the entity in HA. Published with `retain=true`. |
| `{base_topic}/devices/{unique_id}/status` | HNMS → HA | Device presence: `online` or `offline`. Published with `retain=true`. |
| `{base_topic}/devices/{unique_id}/attributes` | HNMS → HA | JSON object with device metadata. Published with `retain=true`. |

### Example Topics (with default base topic)

```
homeassistant/device_tracker/hnms_001122aabbcc/config
network_scanner/devices/hnms_001122aabbcc/status
network_scanner/devices/hnms_001122aabbcc/attributes
```

---

## 3. Discovery Payload

When a device comes online, HNMS publishes the following config payload to the discovery topic:

```json
{
  "name": "My iPhone",
  "unique_id": "hnms_001122aabbcc",
  "state_topic": "network_scanner/devices/hnms_001122aabbcc/status",
  "json_attributes_topic": "network_scanner/devices/hnms_001122aabbcc/attributes",
  "payload_home": "online",
  "payload_not_home": "offline",
  "icon": "mdi:cellphone",
  "device": {
    "identifiers": ["hnms_001122aabbcc"],
    "name": "My iPhone",
    "manufacturer": "Apple, Inc.",
    "model": "Network Device",
    "connections": [["mac", "00:11:22:AA:BB:CC"]]
  }
}
```

> **Entity Type**: HNMS registers devices as **`device_tracker`** entities (not `binary_sensor`). This means they appear in the **People** and **Presence** sections of Home Assistant and can be used for person tracking automations.

---

## 4. Attributes Payload

Each device's attribute topic contains a JSON object with the following fields:

| Field | Example | Description |
|---|---|---|
| `ip_address` | `"192.168.1.42"` | Current IP address |
| `mac_address` | `"00:11:22:AA:BB:CC"` | MAC address |
| `name` | `"my-iphone"` | Hostname as resolved by HNMS |
| `vendor` | `"Apple, Inc."` | MAC vendor (OUI lookup) |
| `type` | `"Mobile"` | Classified device type |
| `ip_type` | `"dynamic"` | `dynamic` or `static` |
| `last_seen` | `"2026-05-08T16:00:00+00:00"` | ISO 8601 UTC timestamp |
| `scanner` | `"HNMS"` | Source identifier |

These are accessible in Home Assistant as `device_tracker.{entity_id}` attributes and can be used in Lovelace cards or automations.

---

## 5. What Triggers a Publish

HNMS publishes device state on every **scan cycle** when a device status changes:

| Event | State Published |
|---|---|
| Device found in scan (ARP/Ping) | `online` + discovery config |
| Device missing from scan | `offline` |
| Manual "Scan Now" triggered | Re-publishes all online devices |

> **Note:** Discovery config is only published when a device comes **online** — not on offline events. This prevents HA from seeing "ghost" entities for permanently gone devices.

---

## 6. Home Assistant Configuration

No YAML is required. After HNMS publishes the discovery payload, Home Assistant will:

1. Automatically create a `device_tracker` entity.
2. Display it under `Settings → Devices & Services → MQTT → Devices`.
3. Show presence as **Home** (`online`) or **Away** (`offline`).

### Viewing in Lovelace

Add a **Glance Card** or **Entity Card** using the auto-created entity ID:

```yaml
type: entity
entity: device_tracker.my_iphone
name: My iPhone
```

### Using in Automations

```yaml
trigger:
  - platform: state
    entity_id: device_tracker.my_iphone
    to: "home"
action:
  - service: light.turn_on
    target:
      entity_id: light.living_room
```

---

## 7. Icon Mapping

Device icons are automatically mapped from the HNMS classification engine to Material Design Icons (`mdi:`) recognized by Home Assistant. Examples:

| HNMS Device Type | Icon |
|---|---|
| Router / Gateway | `mdi:router-network` |
| Mobile / Phone | `mdi:cellphone` |
| Laptop / PC | `mdi:laptop` |
| Smart TV | `mdi:television` |
| IoT / Smart Home | `mdi:home-automation` |
| Unknown | `mdi:lan-connect` |

---

## Troubleshooting

- **Entities not appearing in HA**: Verify the MQTT broker is shared between HNMS and HA. Use [MQTT Explorer](https://mqtt-explorer.com/) to watch the `homeassistant/#` topic for incoming discovery payloads.
- **Entity shows "Unavailable"**: The state topic may not have been published yet. Trigger a manual scan in HNMS to force a re-publish.
- **Wrong entity name**: HNMS uses the device **hostname** as the entity name. Update the hostname in **HNMS → Device Details** and it will be reflected on the next scan.
- **Icon is wrong or missing**: Classification rules drive the icon. Update the matching rule in **Settings → Classification Rules** to change the icon for a device category.
- **`retain=true` not working**: Some brokers have retention disabled. Check your broker config (e.g., Mosquitto: `persistence true` in `mosquitto.conf`).
