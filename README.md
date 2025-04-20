# XMPPMessenger 📱💬

**XMPPMessenger** is a Facebook Messenger–style iOS chat app built in Objective-C, powered by XMPP for real-time communication.  
Originally developed as a stable client for secure, federated internal chat using Apple's native UIKit stack and CocoaPods.

---

## 📦 Features

- **XMPP-Powered Messaging**
  - Realtime chat via [XMPPFramework](https://github.com/robbiehanson/XMPPFramework)
  - Custom login and account handling using `UserSettings`
  - Federated server support (custom domain, port, etc.)

- **Messenger-Style UI**
  - Chat view modeled after Facebook Messenger (circa iOS 9)
  - Channel list with custom `UITableViewCell` layouts
  - Dynamic rendering of avatars, last message previews, and timestamps

- **Multi-User Chat (MUC)**
  - Group creation and joining logic via `CreateMucCell`
  - Channel moderation support

- **Approval Workflow**
  - `ApprovalViewController` manages invites, requests, or other app-based gatekeeping

- **Custom Configurations**
  - `XMPPMessenger_props.plist` for environment config injection
  - `Settings.bundle` for iOS Settings app customization

- **Built With**
  - Objective-C
  - UIKit
  - CocoaPods
  - XMPPFramework

---

## 🧰 Project Structure

- `XMPPMessenger/` – App logic and UI
- `UserSettings.h/.m` – Credential management and user-specific XMPP config
- `Settings.bundle/` – iOS preferences exposed through system settings
- `Podfile` – CocoaPods dependency manager
- `XMPPMessenger_props.plist` – Custom app properties

---

## 🛠 Requirements

- Xcode 9+
- iOS 10+
- CocoaPods (`pod install` before building)

---

## ⚠️ Legacy Notice

This project was originally developed under a personal Apple developer account. While no company data remains, it may require updates to support modern iOS SDKs and XMPPFramework versions.

---

## License

MIT 

---

_Originally crafted to explore federated messaging architectures in native iOS._  
