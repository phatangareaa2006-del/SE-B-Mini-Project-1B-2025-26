# 📚 Group 13 - SE-B Mini Project

## 🏛️ CivicVoice - Public Complaint Registration Platform

A Flutter-based mobile application designed to empower citizens by providing a seamless platform to register, track, and resolve public complaints. Built with a robust Firebase backend, real-time location tracking, and modern Flutter architecture.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 👥 Team Members

<div align="center">

### 🎯 Our Amazing Team

Meet the talented developers building CivicVoice!

</div>

---

### 🏆 Bhumi koli - Team Lead

<div align="center">

![Role: Team Lead](https://img.shields.io/badge/Role-Team%20Lead-blue?style=flat-square)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

</div>


---

### 💻 Sanika Pawar - Developer

<div align="center">

![Role: Developer](https://img.shields.io/badge/Role-Developer-orange?style=flat-square)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)


---

### 🚀 Namrata Dhas - Developer


<div align="center">

![Role: Developer](https://img.shields.io/badge/Role-Developer-orange?style=flat-square)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

</div>


---

### 🚀 Kashish Jain - Developer


<div align="center">

![Role: Developer](https://img.shields.io/badge/Role-Developer-orange?style=flat-square)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

</div>


## 👨‍🏫 Project Guide

### Prof. Sarala Mary

<div align="center">

![Role: Guide](https://img.shields.io/badge/Role-Guide-purple?style=flat-square)
![Institution: APSIT](https://img.shields.io/badge/Institution-APSIT-ff69b4?style=flat-square)

</div>

- **Responsibility**: Project Mentorship & Guidance
- **Expertise**: Software Engineering, Project Management
- **Support**: Architecture Review, Best Practices, Quality Assurance

---

## 📋 Project Overview

CivicVoice bridges the gap between citizens and municipal authorities by streamlining the process of raising public concerns. From capturing real-time location and images to providing dynamic status tracking, the platform ensures transparency and accountability in complaint resolution.

### ✨ Core Features

- **👤 Secure User Authentication**: Email/Password and Google OAuth integration.
- **📸 Intelligent Complaint Registration**: Lodge complaints with live photos attached.
- **📍 Real-Time Geolocation**: Pinpoint exact issue locations using device GPS.
- **📊 Dynamic Status Tracking**: Follow complaint lifecycles (e.g., Pending, In Progress, Resolved).
- **🗺️ Interactive Map Integration**: Easy navigation to complaint sites via Google Maps.
- **👥 Customizable Profiles**: Manage personal data and issue logs easily.

### 🛡️ Admin Features
- **📋 Master Dashboard**: Overview of all active and resolved complaints.
- **✏️ One-Tap Status Updates**: Dynamically edit the real-time status of complaints.
- **🖼️ Image & Data Parsing**: Review submitted evidence and coordinate details directly on external maps.
- **🔐 Secure Role Management**: Protected admin shell restricted to authorized personnel.

---

## 🏗️ Project Architecture

CivicVoice follows a clean **layered architecture** design:

```
lib/
├── screens/                 # Presentation Layer
│   ├── admin/               # Admin dashboard and controls
│   ├── auth/                # Login, Signup, and Authentication screens
│   └── user/                # Complaint forms, Tracking, Profile, etc.
├── models/                  # Data Models (e.g., ComplaintModel)
├── services/                # Firebase & Map API integrations
├── utils/                   # Helper files and utilities
└── main.dart                # Application entry point
```

---

## 🛠️ Tech Stack

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State%20Management-2196F3?style=for-the-badge&logo=flutter&logoColor=white)
![Material Design 3](https://img.shields.io/badge/Material%20Design%203-UI-757575?style=for-the-badge&logo=material-design&logoColor=white)

### Backend & Core Services
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Cloud Firestore](https://img.shields.io/badge/Cloud%20Firestore-Database-FFA726?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase Auth](https://img.shields.io/badge/Firebase%20Auth-Authentication-FFA726?style=for-the-badge&logo=firebase&logoColor=white)

### Device Integrations
![Geolocator](https://img.shields.io/badge/geolocator-Device%20GPS-4CAF50?style=for-the-badge)
![URL Launcher](https://img.shields.io/badge/url_launcher-Google%20Maps-FF7043?style=for-the-badge)
![Image Picker](https://img.shields.io/badge/image_picker-Media%20Selection-9C27B0?style=for-the-badge)

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (3.x+)
- Dart SDK (3.x+)
- Firebase CLI
- Android Studio / VS Code

### Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Bhumikoli/SE-B-Mini-Project-1B-2025-26.git
   cd public_compaint_registration_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Connect the project to your Firebase instance using `flutterfire configure`.
   - Ensure the generated `firebase_options.dart` is in the `lib` folder.
   - Add your `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 🔐 System Rules & Security

### Firestore Database Schema
- **users** - Stores resident/admin properties, preferences, and roles.
- **complaints** - Tracks issue details, coordinate payloads, image references, and dynamic statuses.

### Security Rules
- Read/Write privileges scoped strictly to the authenticated user.
- Admin portal governed by custom claims or specific UI verification loops to restrict overriding functionalities.

---

## 🛡️ Admin Portal

The Admin Portal is a **separate protected shell** within CivicVoice, accessible only to authorized municipal personnel. It provides full oversight and control over all citizen-submitted complaints across the platform.

### 🔐 Admin Access & Role Management

Admin access is enforced at the application entry point (`_AuthGate` in `main.dart`). The authentication flow distinguishes between citizen and admin roles, routing each to their respective shell:

```
_AuthGate (main.dart)
  ├── Not logged in  →  LoginScreen
  ├── Citizen role   →  UserShell  (citizen-facing portal)
  └── Admin role     →  AdminShell (protected admin portal)
```

Admin users are verified through **Firebase Auth custom claims** or a UI-level role check against the `users` collection in Firestore, where an `isAdmin: true` flag restricts entry into the admin shell.

---

### 📊 Admin Dashboard (`DashboardScreen`)

The Admin Dashboard provides a **real-time overview** of all complaints across all wards and categories.

#### Stats Overview Grid
| Card | Metric | Sub-info |
|---|---|---|
| 📋 Total Complaints | 1,284 | +24 this week |
| ✅ Resolved | 876 | 68% resolution rate |
| ⚙️ In Progress | 163 | Avg. 4.2 days |
| ⏳ Pending | 245 | Needs attention |

#### Dashboard Sections
- **Recent Complaints Panel** — Displays the 4 latest complaints with category icon, complaint ID, date, and live status badge.
- **Department Performance Panel** — Color-coded progress bars showing per-category resolution rate:
  - 🟢 Green: ≥ 80% resolved
  - 🟠 Orange: 60–79% resolved
  - 🔴 Red: < 60% resolved
- **Quick Actions Bar** — One-tap navigation to File Complaint, Track Complaint, Analytics, and All Complaints.

---

### 📋 Complaint Management (`AllComplaintsScreen`)

The admin's primary workspace for viewing, filtering, and acting on all submitted complaints.

#### Filtering & Search
- **Status Filter** (pill chips): `All` · `Pending` · `In Progress` · `Resolved`
- **Category Dropdown**: Filter by any of the 8 issue categories (Roads, Water, Electricity, etc.)
- **Live complaint count** updates as filters change.

#### Complaint Card Details
Each complaint row displays:
- Category icon with a **color-coded left border** unique to the issue type
- Complaint title + **Priority Badge** (LOW / MEDIUM / HIGH / CRITICAL)
- Metadata chips: 🆔 ID · 📅 Date · 📍 Location · 🏛️ Ward · 👤 Assigned To
- **Status Badge** (color-coded: Pending / In Progress / Resolved / Rejected)
- **Upvote counter** — shows community support for an issue

#### Admin Actions
- **One-Tap Status Update** — Admin can change a complaint's status (Pending → In Progress → Resolved / Rejected) directly from the list view, which writes back to Firestore in real time.
- **Image Evidence Viewer** — Admin can review photos submitted by the citizen as base64-encoded attachments.
- **Map Redirect** — Tapping the location field launches Google Maps (via `url_launcher`) to the exact complaint coordinates.

---

### 📈 Analytics & Reports (`AnalyticsScreen`)

A dedicated analytics module offering data-driven insights on platform and municipal performance.

#### KPI Cards
| Metric | Value | Trend |
|---|---|---|
| ⏱️ Avg. Resolution Time | 4.2 days | ↓ 0.8 days vs last month |
| 😊 Citizen Satisfaction | 78% | ↑ 3% vs last month |
| 📬 Response Rate | 94.2% | ↑ 1.2% vs last month |

#### Charts & Visualizations
- **📊 Monthly Complaint Trend** — A custom bar chart showing complaint volume across all 12 months (J–D). Built with `CustomPaint` — no external charting library required.
- **🟠 Status Distribution** — Horizontal progress bars showing the breakdown of Resolved / In Progress / Pending complaints with percentage labels.
- **🎯 Category-wise Resolution Performance** — A grid of **donut charts**, one per issue category, each rendered with `CustomPainter` showing the resolution percentage for that category:

```
Roads      → 72%   |  Water       → 85%
Electricity → 90%  |  Sanitation  → 60%
Parks       → 55%  |  Drainage    → 68%
```

---

### 🏗️ Admin Shell Architecture

```
lib/
├── screens/
│   ├── dashboard_screen.dart       # Admin overview (stats, recent, dept perf)
│   ├── complaints_screen.dart      # Full complaint list with filters & upvotes
│   ├── analytics_screen.dart       # KPI cards, bar chart, donut charts
│   ├── register_screen.dart        # Admin-side complaint registration view
│   └── track_screen.dart           # Complaint tracking by ID
├── user_shell.dart                 # Admin shell with bottom nav (5 tabs)
└── auth/
    └── login_screen.dart           # Shared auth entry point
```

#### Admin Navigation Bar (5 Tabs)
| Tab | Icon | Screen |
|---|---|---|
| 0 | 📊 Dashboard | Overview stats & recent activity |
| 1 | ✏️ File (FAB) | Register a new complaint |
| 2 | 🔍 Track | Search complaint by ID |
| 3 | 📋 Complaints | Full list with filters |
| 4 | 📈 Analytics | KPI & charts |

The center nav item is styled as a **gold floating action button** with a glow shadow, providing a premium feel for the primary action.

---

## 📅 Project Development Matrix

### 🎯 Key Workflow Sprints

<div align="center">

| **Phase** | **Workstream** | **S1** | **S2** | **S3** | **S4** |
|:---:|:---|:---:|:---:|:---:|:---:|
| **🏗️ Foundation** | 🏢 App architecture styling & Firebase setup | ██ | | | |
| **👤 Access** | 🔐 Authentication (Email + Google) & Profiles | | ██ | | |
| **📋 Core Loop** | 📸 Media Pickers & Real-Time Geolocation | | ██ | ██ | |
| **🛡️ Admin HQ** | 👨‍💼 Dynamic Status Handlers & DB Queries | | | ██ | ██ |
| **✅ Finalization** | ⚡ UI Refinements, Bug Fixes & Map Redirects | | | | ██ |

</div>

---

## 🚀 Development Guide

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# iOS Bundle
flutter build ios --release
```

---

## 🤝 Contributing

We welcome contributions! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingUpdate`)
3. Commit your changes (`git commit -m 'Add AmazingUpdate'`)
4. Push to the branch (`git push origin feature/AmazingUpdate`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **APSIT** - For fostering a great academic and development environment.
- **Prof. Sarala Mary** - For continuous guidance and mentorship.
- **Flutter & Firebase Communities** - For exceptional documentation and packages.

---

## 📞 Contact & Support

For queries, bug reports, and features:

- **Bhumi koli **: [GitHub](https://github.com/Bhumikoli/) 

---

**Project Status**: Active Development
