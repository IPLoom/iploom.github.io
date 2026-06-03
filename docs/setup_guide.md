# Setup Guide

IPLoom is designed to be flexible. You can run it as a production-ready Docker container, set it up manually for development, or install the companion Mobile App.

## 📱 Mobile App (Android Companion)

Download the official Android mobile application:

<a href="./iploom-mobile.apk" download class="inline-flex items-center justify-center px-5 py-2.5 bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg font-bold transition-all shadow-md shadow-emerald-950/20 text-sm my-2">
  Download Android APK (iploom-mobile.apk)
</a>

---

## 🐋 Docker Image

The official IPLoom Docker image is available on Docker Hub:

```bash
docker pull wglabz/iploom:latest
```

[View on Docker Hub →](https://hub.docker.com/r/wglabz/iploom)

---

## 🐋 Docker Setup (Recommended)

Docker is the easiest way to get IPLoom running with all its dependencies pre-configured.

### 1. Requirements
- Docker and Docker Compose.
- **Linux Host**: Highly recommended for full Scapy performance (`network_mode: host`).

### 2. Environment Variables

Configure the container behavior using these environment variables:

| Variable | Default | Description |
| :--- | :--- | :--- |
| `APP_ENV` | `production` | Set to `development` for debug logging. |
| `DB_PATH` | `/data/network_scanner.duckdb` | Path to the database file inside the container. |
| `DB_SCHEMA_PATH` | `app/schema.sql` | Path to the schema file inside the container. |
| `WORKERS` | `1` | Number of concurrent scan workers (1 is recommended for Raspberry Pi). |
| `MQTT_ENABLED` | `false` | Set to `true` to enable MQTT publishing. |
| `MQTT_HOST` | `localhost` | IP/Hostname of your MQTT broker. |

### 3. Docker Compose
Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  iploom:
    image: wglabz/iploom:latest
    container_name: iploom
    network_mode: host # Required for Scapy discovery
    volumes:
      - ./iploom_data:/data
    environment:
      - APP_ENV=production
      - DB_PATH=/data/network_scanner.duckdb
    restart: unless-stopped
```

### 4. Persistent Storage
To preserve your device history and configuration across container updates, map a local directory to `/data`:

```yaml
volumes:
  - ./iploom_data:/data
```

### 5. Networking Requirements (Linux)
The scanner requires raw socket access to perform ARP requests.
- **Host Mode** (`network_mode: host`): Gives the scanner full access to the host network interface. **Recommended.**
- **Bridge Mode**: If using bridge mode, MAC address resolution will be limited to the container's virtual interface.

> [!IMPORTANT]
> For Linux deployments, always use `network_mode: host` to allow the scanner full access to the network interface.

### 6. Launch
```bash
docker-compose up -d
```
Access the UI at `http://localhost:8000`.

---

## 💻 Manual Development Setup

If you want to contribute to the project or run it natively:

### Backend (FastAPI)
1.  **Install Python 3.9+**.
2.  **Install Npcap (Windows Only)**: Required for Scapy.
3.  **Setup Environment**:
    ```bash
    cd backend
    python -m venv venv
    source venv/bin/activate # or venv\Scripts\activate
    pip install -r requirements.txt
    ```
4.  **Run**:
    ```bash
    # Note: Must run as Admin/Sudo for scanning
    python -m uvicorn app.main:app --reload --port 8001
    ```

### Frontend (Vue 3)
1.  **Install Node.js**.
2.  **Setup**:
    ```bash
    cd ui
    npm install
    ```
3.  **Run**:
    ```bash
    npm run dev
    ```

---

## 🛠️ Windows Troubleshooting

### 1. Install Npcap
The scanner uses Scapy, which requires a packet capture driver on Windows.
- Download and install **[Npcap](https://npcap.com/#download)**.
- **IMPORTANT**: Ensure "Install Npcap in WinPcap API-compatible Mode" is checked during installation.

### 2. Run as Administrator
Sending raw network packets (ARP) requires high-level privileges. Always open your terminal (PowerShell or CMD) as **Administrator** before running the backend.

### 3. Automatic Fallback
The system includes a smart fallback. If raw ARP packets are restricted by your security policy, IPLoom will automatically pivot to a **Parallel Ping Sweep**. This ensures devices are found even without specialized drivers.

### 4. Firewall
If devices are not being found:
- Ensure the devices are on the same subnet as the host.
- Temporarily disable host firewall to test if ARP packets are being blocked.
