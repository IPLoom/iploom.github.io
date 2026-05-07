# Setup Guide

HNMS is designed to be flexible. You can run it as a production-ready Docker container or set it up manually for development.

## 🐋 Docker Setup (Recommended)

Docker is the easiest way to get HNMS running with all its dependencies pre-configured.

### 1. Requirements
- Docker and Docker Compose.
- **Linux Host**: Highly recommended for full Scapy performance (`network_mode: host`).

### 2. Docker Compose
Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  hnms:
    image: wglabz/hnms:latest
    container_name: hnms
    network_mode: host # Required for Scapy discovery
    volumes:
      - ./hnms_data:/data
    environment:
      - APP_ENV=production
      - DB_PATH=/data/network_scanner.duckdb
    restart: unless-stopped
```

### 3. Launch
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

### Npcap Configuration
The scanner uses Scapy, which requires a packet capture driver. 
- Download: **[Npcap](https://npcap.com/#download)**.
- **IMPORTANT**: Ensure "Install Npcap in WinPcap API-compatible Mode" is checked during installation.

### Permissions
Sending raw network packets (ARP) requires high-level privileges. Always open your terminal as **Administrator** before running the backend.

### Firewall
If devices are not being found:
- Ensure the devices are on the same subnet as the host.
- Temporarily disable host firewall to test if ARP packets are being blocked.
