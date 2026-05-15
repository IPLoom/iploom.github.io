# 🛡️ IPLoom Documentation Hub

Welcome to the official documentation for **IPLoom** — a professional-grade, web-based network monitoring and security suite for the modern home. This guide provides comprehensive technical details, architectural overviews, and integration instructions for the platform.

## 🚀 Getting Started

If you are new to IPLoom, start with these guides:
- **[Installation & Setup](./docs/setup_guide.md)**: How to deploy IPLoom via Docker or manual setup.
- **[Architecture Overview](./docs/architecture.md)**: Understand the tech stack and system flow.

## 🛠️ Technical Deep Dives

Learn how the core engines of IPLoom work under the hood:
- **[Scanning Engine](./docs/scanning_engine.md)**: Layer 2 discovery, Ping Sweeps, and Port Scanning logic.
- **[Device Classification](./docs/classification_rules.md)**: How the dynamic rule engine identifies your hardware.
- **[Database Schema](./docs/database_schema.md)**: Details on DuckDB storage and historical tracking.

## 📡 Integrations & Connectivity

Connect IPLoom to your existing ecosystem:
- **[MQTT & Home Assistant](./docs/mqtt_integration.md)**: Real-time presence tracking and automation.
- **[Home Assistant Integration](./docs/home_assistant_integration.md)**: Full MQTT Discovery guide for HA.
- **[OpenWrt Integration](./docs/openwrt_integration.md)**: Traffic monitoring, DHCP lease syncing, and **Immediate Device Blocking**.
- **[AdGuard Home Integration](./docs/adguard_integration.md)**: DNS analytics and per-device block tracking.

## 💻 Developer Resources

- **[API Reference](./docs/api_reference.md)**: REST API endpoints and data structures.
- **Interactive Documentation**: Available at `http://{host}:8000/docs` on your running instance.

---

### 🌟 About IPLoom
IPLoom is built with a focus on **privacy, performance, and visibility**. By keeping all your network data local and providing granular control over device identification, it serves as a professional-grade audit tool for the modern smart home.

---
<div align="center">
Built with ❤️ for the Home Automation Community
</div>
