# BhoomiSetu - Field Officer Mobile Application

**National Land Acquisition & Management System**  
*Ministry of Rural Development & Land Resources • Government of India*

---

## 📌 Project Overview
The **BhoomiSetu Field Officer Mobile Application** is a production-grade, offline-first Flutter application designed for on-site field verification officers conducting statutory land surveys, GPS coordinate logging, parcel verification, cadastral inspections, photographic evidence gathering, and document synchronization across India.

---

## 📱 Features & Highlights

- **🏛️ National Government Design System**: Built with modern Government of India branding, high-contrast outdoor readability, Saffron (`#D9531E`) and Deep Navy (`#0D1B2A`) palettes, and accessible UI touch targets (≥ 48dp).
- **🛰️ High-Precision GPS Capture**: Real-time GNSS coordinate capture with accuracy threshold validation (±15m threshold alert), altitude tracking, and geodesic distance offset calculations from cadastral centroids.
- **📋 5-Section Statutory Inspection Checklist**: Comprehensive form covering Parcel Identification, Boundary & Demarcation, Land Condition & Use, Ownership & Title Review, and Objections & Dispute recording.
- **📸 Geo-Tagged Evidence & Media**: Integrated camera capture with category tagging (*Parcel Boundary, Land Condition, Existing Structure, Ownership Evidence, Road/Access*), metadata persistence (SQLite), and image preview/deletion.
- **📁 Document Manager**: Attached statutory documents (e.g. 7/12 Land Extract, Mutation records, NOCs, Objections).
- **🔄 Offline-First & Idempotent Sync Engine**: Fully operational without internet connectivity. Submissions are persisted in local encrypted SQLite and queued in `sync_queue` with unique `clientEventId` idempotency keys and exponential backoff retry.
- **🗺️ Cadastral Parcel Map**: Leaflet / OpenStreetMap integration displaying assigned parcel boundaries, markers, and officer location with graceful offline vector fallback.
- **🔔 Real-Time Notifications**: Local and WebSocket-ready event streams for task assignments, verification reviews, and sync alerts.
- **⚙️ Configurable Data Layer**: Seamless switching between standalone `MockRepository` (demo mode) and `ApiRepository` (Aditya's API Gateway).

---

## 🛠️ Architecture

```
                    FLUTTER FIELD APP
                           │
                           ▼
                    UI / FEATURES
                           │
                           ▼
                  RIVERPOD / STATE
                           │
                           ▼
                    REPOSITORIES
                    /           \
                   /             \
                  ▼               ▼
          LOCAL DATA          REMOTE API
             │                    │
             ▼                    ▼
        SQLite / Files       API Client
             │                    │
             └──────────┬─────────┘
                        │
                        ▼
                 ADITYA'S API
                   GATEWAY
                        │
                        ▼
              PostgreSQL / PostGIS
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `^3.47.2` (Channel stable)
- **Dart SDK**: `^3.13.2`
- **Android SDK**: API level 23+ (Targeting Android 14 / 15 / 16)
- **Physical Device or Android Emulator**: USB debugging enabled

### Installation & Run

1. **Clone the repository**:
   ```bash
   cd field-officer-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Launch on connected Android device**:
   ```bash
   flutter run -d <device_id>
   ```

---

## 🔑 Demo Credentials

| Field | Value |
| :--- | :--- |
| **Official Email** | `field.demo@bhoomisetu.gov.in` |
| **Password** | `demo@123` |
| **Officer Name** | Rajesh Kumar |
| **Officer ID** | `FO-MH-PUN-0842` |
| **Designation** | Senior Field Survey Officer |
| **Assigned Project** | Pune Ring Road Express Corridor |
| **Assigned Jurisdiction**| Pune District, Maharashtra |

---

## 📦 Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants, API endpoints, demo credentials
│   ├── theme/           # Color tokens, typography, Material 3 theme
│   ├── network/         # ApiClient, ApiConfig, ApiExceptions, WebSocket
│   ├── storage/         # DatabaseHelper (SQLite), SecureStorage
│   ├── permissions/     # Runtime camera & location permission handler
│   ├── utils/           # GeoUtils, DateFormatter, Validators
│   └── widgets/         # Government AppBar, StatusBadge, Buttons, MetricCard
├── data/
│   ├── models/          # Strongly typed models with toJson/fromJson
│   ├── datasources/     # Mock data source & local SQLite DAOs
│   └── repositories/    # Auth, Task, Visit, Evidence, Document, Sync
├── features/
│   ├── splash/          # Splash branding & session restoration
│   ├── auth/            # Official Field Officer Login
│   ├── dashboard/       # Field Officer Dashboard & Navigation Wrapper
│   ├── tasks/           # Assigned tasks list & task details
│   ├── field_visit/     # Start visit, GPS capture, Parcel verification, Review
│   ├── inspection/      # 5-section checklist form with validation
│   ├── evidence/        # Camera capture & photo gallery
│   ├── documents/       # File picker & document upload queue
│   ├── map/             # Interactive parcel map with offline fallback
│   ├── notifications/   # System & assignment alerts
│   ├── profile/         # Officer profile, jurisdiction, logout
│   ├── progress/        # Performance metrics & completion charts
│   ├── sync/            # Offline Sync Center & manual queue manager
│   └── settings/        # Data mode switch (Mock/API) & base URL config
└── services/
    ├── location_service.dart
    ├── camera_service.dart
    ├── connectivity_service.dart
    └── sync_service.dart
```

---

## 🧪 Testing

Execute automated unit, model, and widget tests:
```bash
flutter test
```

Execute static code analysis:
```bash
flutter analyze
```

Build debug APK:
```bash
flutter build apk --debug
```

---

## 📜 Team Boundary & API Contract
- For detailed REST and WebSocket contracts agreed with backend developer Aditya, see [docs/API_INTEGRATION.md](docs/API_INTEGRATION.md).
