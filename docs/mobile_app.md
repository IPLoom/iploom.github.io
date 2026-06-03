# IPLoom Mobile Application

The **IPLoom Mobile App** is a companion mobile client built with Flutter, allowing administrators to monitor, manage, and interact with the Home Network Management System (HNMS) backend directly from mobile devices.

---

## 📱 Technical Architecture

The mobile client mirrors the functionality of the Web UI, communicating with the backend over standard REST APIs, and storing persistent settings locally.

- **Cross-Platform Framework**: [Flutter](https://flutter.dev/) for native performance on Android and iOS.
- **State Management**: [Provider](https://pub.dev/packages/provider) for managing reactive application state (e.g. dashboards, logs, active devices).
- **Network Layer**: [Dio](https://pub.dev/packages/dio) HTTP client with interceptors for JWT injection and centralized error handling.
- **Local Settings**: [Shared Preferences](https://pub.dev/packages/shared_preferences) for caching connection profiles, backend URLs, and user authentication tokens.

---

## 🛠️ Main Features

### 1. Dynamic Server Configuration
- Connect to any local or remote IPLoom backend instance.
- Dynamically update the backend IP/domain directly in the configuration tab.

### 2. Five-Tab Central Navigation
1.  **Config**: Credentials management, server URL, theme setup, and server connection verification.
2.  **Devices**: Interactive list of discovered devices with vendor tags, search filters, and status flags.
3.  **Dashboard**: Centralized hub presenting system health, DNS statistics, active alerts, and real-time scanning progress.
4.  **Analytics**: Bandwidth utilization, DNS query block rates, and query latency distributions.
5.  **Logs**: Real-time server and worker activity logs.

### 3. Integrated SSH Terminal Client
The mobile app features a fully integrated SSH Terminal client built using native Dart protocols. This enables direct administrative shell access to network hosts (such as routers, servers, or Raspberry Pis) from the mobile interface.

- **Package Stack**: Utilizes [dartssh2](https://pub.dev/packages/dartssh2) for the SSH transport layers and [xterm.dart](https://pub.dev/packages/xterm) for rendering standard ANSI terminal sequences.
- **Authentication**: Supports both username/password credentials and **SSH Key Authentication** (PEM private keys).
- **Command History Buffer**: Tracks executed commands in-memory. Users can pull up a bottom-sheet command history panel by tapping the history icon to re-execute past commands.
- **Interactive Font Scaling**: Action buttons in the terminal app bar allow scaling the text size dynamically to adjust for mobile readability.
- **Visual Status Dot**: Renders real-time connection status (connecting, success, disconnected/error) with descriptive diagnostic logs.

---

## 🔑 Setup and Authentication

1. Download or build the IPLoom APK (`iploom-mobile.apk` located in the root of the Docs build output) or deploy to your iOS device.
2. Open the app and navigate to the **Config** tab.
3. Enter your backend API URL (e.g., `http://192.168.0.10:8000`).
4. Enter your login credentials (username and password) configured in the backend's user registry.
5. Tap **Verify** to test connection stability. Once successful, the application stores the received JWT token to keep you logged in.
