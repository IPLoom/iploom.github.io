# Setup Guide

IPLoom is designed to be flexible. You can run it as a production-ready Docker container, set it up manually for development, or install the companion Mobile App.

## 📱 Mobile App (Android Companion)

Download the official Android mobile application:

<div class="download-card">
  <div class="download-icon-wrapper">
    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <rect x="5" y="2" width="14" height="20" rx="2" ry="2" stroke-width="2"></rect>
      <line x1="12" y1="18" x2="12.01" y2="18" stroke-width="2" stroke-linecap="round"></line>
    </svg>
  </div>
  <div class="download-info-wrapper">
    <h4>Android Companion App</h4>
    <p>Install the companion app for real-time presence tracking, push notifications, and local SSH terminal management.</p>
  </div>
  <a href="./iploom-mobile.apk" download class="download-action-btn">
    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
    </svg>
    Download APK
  </a>
</div>

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
Access the UI at `http://localhost` (port 80).

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
    python -m uvicorn app.main:app --reload --port 8000
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
