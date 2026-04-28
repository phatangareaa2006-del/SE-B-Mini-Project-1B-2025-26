# 📚 Group 12 - SE-B Mini Project

## 🎓 CodeClub - Team Finder & Hackathon Management Platform

A Flutter-based mobile application designed exclusively for **APSIT students** to find their perfect hackathon team members, create and manage teams, and register for hackathons. Built with Firebase backend and modern Flutter architecture.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 👥 Team Members

<div align="center">

### 🎯 Our Amazing Team

Meet the talented developers building CodeClub!

</div>

---

### 🏆 Pushkar Shinde - Team Lead

<div align="center">

![Role: Team Lead](https://img.shields.io/badge/Role-Team%20Lead-blue?style=flat-square)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

</div>

| **Details** | |
|:---|:---|
| **GitHub** | [@Pushkar3232](https://github.com/Pushkar3232/) |
| **Portfolio** | [pushkarshinde.in](https://pushkarshinde.in) |
| **Email** | Reach out via GitHub |
| **Focus Areas** | Architecture Design, Project Management, Backend Integration |
| **Key Contributions** | Project Setup, Firebase Configuration, System Architecture |

---

### 💻 Sagar Pradhan - Developer

<div align="center">

![Role: Developer](https://img.shields.io/badge/Role-Developer-orange?style=flat-square)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

</div>

| **Details** | |
|:---|:---|
| **GitHub** | [@sagar717-creator](https://github.com/sagar717-creator) |
| **Focus Areas** | UI/UX Implementation, Feature Development |
| **Key Contributions** | Chat Features, User Interface, Real-time Messaging |

---

### 🚀 Vighnesh Pingale - Developer


<div align="center">

![Role: Developer](https://img.shields.io/badge/Role-Developer-orange?style=flat-square)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

</div>

| **Details** | |
|:---|:---|
| **GitHub** | [Vighnesh279](https://github.com/Vighnesh279) |
| **Focus Areas** | Feature Development, Database Design |
| **Key Contributions** | Admin Module, Security Implementation, Data Management |

---

## 👨‍🏫 Project Guide

### Prof. Harsha Zope

<div align="center">

![Role: Guide](https://img.shields.io/badge/Role-Guide-purple?style=flat-square)
![Institution: APSIT](https://img.shields.io/badge/Institution-APSIT-ff69b4?style=flat-square)

</div>

- **Responsibility**: Project Mentorship & Guidance
- **Expertise**: Software Engineering, Project Management
- **Support**: Architecture Review, Best Practices, Quality Assurance

---

## 📋 Project Overview

CodeClub is an innovative platform that addresses a critical need in the college community — connecting students with the right team members for hackathons and competitive events. This application streamlines the process of team formation, provides intelligent matching based on skills and interests, and offers a comprehensive hackathon management system.

### ✨ Core Features

- **👤 User Profiles**: Complete profile setup with skills, branch, year, and bio
- **🔍 Smart Team Matching**: Discover team members based on skills, roles, and academic background
- **👥 Team Management**: Create teams, send invitations, and manage team members
- **💬 Real-time Chat**: Communicate with team members and community
- **🏆 Hackathon Hub**: Browse, register, and manage hackathon participation
- **🤖 AI Mentor**: Intelligent chatbot for guidance and support
- **💬 Community Chat**: Connect with the broader APSIT community
- **🔔 Notifications**: Real-time push notifications for team activities and events
- **🌐 Offline Support**: Basic functionality available without internet

### Admin Features
- **📊 Hackathon Management**: Create and manage hackathons
- **👨‍💼 User Management**: Manage user accounts and roles
- **⚙️ System Configuration**: Control app-wide settings
- **📈 Analytics & Insights**: View statistics and user engagement

---

## 🏗️ Project Architecture

CodeClub follows a **layered architecture** pattern for clean code separation:

```
lib/
├── ui/                    # Presentation Layer (Screens & Widgets)
│   ├── screens/          # Feature-based screens
│   ├── widgets/          # Reusable UI components
│   ├── admin/            # Admin dashboard
│   └── navigation/       # App routing (GoRouter)
├── data/                 # Data Layer
│   ├── services/         # Firebase & API services
│   └── models/           # Data models
├── features/             # Feature-specific logic
│   ├── ai_mentor/        # AI mentor feature
│   └── ...
├── providers/            # State Management (Provider)
├── core/                 # Core Utilities & Constants
│   ├── constants/        # App constants
│   ├── theme/            # Theme configuration
│   └── utils/            # Helper utilities
└── main.dart             # App entry point
```

---

## 🛠️ Tech Stack

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State%20Management-2196F3?style=for-the-badge&logo=flutter&logoColor=white)
![GoRouter](https://img.shields.io/badge/GoRouter-Navigation-4285F4?style=for-the-badge&logo=flutter&logoColor=white)
![Material Design 3](https://img.shields.io/badge/Material%20Design%203-UI-757575?style=for-the-badge&logo=material-design&logoColor=white)

### Backend & Services
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Cloud Firestore](https://img.shields.io/badge/Cloud%20Firestore-Database-FFA726?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase Auth](https://img.shields.io/badge/Firebase%20Auth-Authentication-FFA726?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase Storage](https://img.shields.io/badge/Firebase%20Storage-Cloud%20Storage-FFA726?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase App Check](https://img.shields.io/badge/Firebase%20App%20Check-Security-FFA726?style=for-the-badge&logo=firebase&logoColor=white)

### Additional Libraries
![Image Caching](https://img.shields.io/badge/cached_network_image-Image%20Optimization-FF6B6B?style=for-the-badge)
![Notifications](https://img.shields.io/badge/flutter_local_notifications-Push%20Notifications-4CAF50?style=for-the-badge)
![Connectivity](https://img.shields.io/badge/connectivity_plus-Network%20Detection-2196F3?style=for-the-badge)
![Image Picker](https://img.shields.io/badge/image_picker-Media%20Selection-9C27B0?style=for-the-badge)
![URL Launcher](https://img.shields.io/badge/url_launcher-Link%20Handler-FF7043?style=for-the-badge)
![Lottie](https://img.shields.io/badge/lottie-Animations-3498db?style=for-the-badge)
![Markdown](https://img.shields.io/badge/flutter_markdown-Markdown%20Rendering-083fa1?style=for-the-badge)

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase CLI (for backend setup)
- Android Studio / Xcode (for emulators)

### Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Pushkar3232/codeclub.git
   cd codeclub
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 🔐 Firebase Configuration

### Authentication Setup
- Email & Password authentication enabled
- Custom claims for admin role management
- User verification and security best practices

### Firestore Database Structure
- **users** - User profiles and metadata
- **teams** - Team information and members
- **hackathons** - Hackathon events
- **invitations** - Team member invitations
- **messages** - Chat messages
- **notifications** - User notifications

### Security Rules
- Role-based access control (RBAC)
- User data protection and privacy
- Admin-only operations secured

---

## 📁 Directory Structure

Detailed project organization:

```
codeclub/
├── lib/
│   ├── main.dart              # App entry point
│   ├── firebase_options.dart  # Firebase configuration
│   ├── core/                  # Core utilities & constants
│   ├── data/                  # Data models & services
│   ├── features/              # Feature modules
│   ├── providers/             # State management
│   └── ui/                    # UI screens & widgets
├── assets/                    # Images & media
├── pubspec.yaml               # Package dependencies
├── firebase.json              # Firebase config
└── README.md                  # Documentation
```

---

## � Project Timeline (Gantt Chart)

### 🎯 12-Week Sprint Schedule

<div align="center">

| **Phase** | **Workstream** | **W1** | **W2** | **W3** | **W4** | **W5** | **W6** | **W7** | **W8** | **W9** | **W10** | **W11** | **W12** |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **🏗️ Foundation** | 🏢 Project setup & architecture | ██ | ██ | | | | | | | | | | |
| | 🔥 Firebase config + schema | ██ | ██ | ██ | | | | | | | | | |
| **👤 Auth & Profile** | 🔐 Auth + profile core | | ██ | ██ | | | | | | | | | |
| | 🔗 Social links profile flow | | | | ██ | ██ | | | | | | | |
| **🔍 Discovery & Teams** | 👥 Member discovery + team flows | | | | ██ | ██ | ██ | | | | | | |
| | 🏆 Hackathon listing + details | | | | | ██ | ██ | | | | | | |
| | 📝 Applications + my applications | | | | | | ██ | ██ | | | | | |
| **💬 Communication** | 💭 Private/group chat | | | | | ██ | ██ | ██ | | | | | |
| | 📢 Community broadcast chat | | | | | | ██ | ██ | ██ | | | | |
| | 🔔 Chat notifications | | | | | | | ██ | ██ | | | | |
| **⚙️ Advanced Features** | 🌐 Connectivity/offline handling | | | | | | | | ██ | ██ | | | |
| | 🤖 AI mentor (UI + API + UX) | | | | | | | | | ██ | ██ | ██ | |
| **🛡️ Admin & Security** | 👨‍💼 Admin module (auth + CRUD) | | | | | | | | | ██ | ██ | ██ | |
| | 🔒 Security rules + indexes | | | | | | | | | | ██ | ██ | ██ |
| **✅ Quality & Release** | ⚡ Performance + stability pass | | | | | | | | | | | ██ | ██ |
| | 🧪 Testing (unit/widget/integration) | | | | | | | | | | | ██ | ██ |
| | 🐛 UAT + bug fixing | | | | | | | | | | | | ██ |
| | 📚 Documentation + handover | | | | | | | | | | | ██ | ██ |
| | 📦 Store/release prep | | | | | | | | | | | | ██ |
| | 🚀 **Production rollout** | | | | | | | | | | | | **▲** |

</div>

### 📊 Phase Breakdown

| Phase | Duration | Focus Area |
|:---:|:---|:---|
| 🏗️ **Foundation** | Weeks 1-3 | Core setup & infrastructure |
| 👤 **Auth & Profile** | Weeks 2-4 | User authentication & profiles |
| 🔍 **Discovery & Teams** | Weeks 4-7 | Core features - matching & hackathons |
| 💬 **Communication** | Weeks 5-8 | Chat & messaging systems |
| ⚙️ **Advanced Features** | Weeks 8-11 | AI mentor & offline support |
| 🛡️ **Admin & Security** | Weeks 9-12 | Admin tools & security hardening |
| **✅ Quality & Release** | Weeks 10-12 | Testing, UAT & deployment |

### 🎨 Legend

| Symbol | Meaning | Details |
|:---:|:---|:---|
| ██ | Active Development | Sprint is actively working on this task |
| ▲ | Release/Deployment | Go-live & production rollout |

### 📈 Progress Milestones

- **Week 3** ✓ MVP foundation ready (setup + Firebase + auth)
- **Week 6** ✓ Core features launched (discovery + hackathons)
- **Week 9** ✓ All features complete (chat + AI mentor + admin)
- **Week 11** ✓ Quality assurance complete (testing + UAT)
- **Week 12** 🚀 **Live in Production**

---

## �🚀 Development Guide

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Hot Reload During Development
```bash
flutter run
# Press 'r' for hot reload, 'R' for hot restart
```

---

## 🤝 Contributing

We welcome contributions! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **APSIT** - For providing the academic environment and resources
- **Prof. Harsha Zope** - For guidance and mentorship throughout the project
- **Flutter Community** - For excellent documentation and community support
- **Firebase** - For providing robust backend infrastructure

---

## 📞 Contact & Support

For questions, suggestions, or support:

- **Pushkar Shinde**: [GitHub](https://github.com/Pushkar3232/) | [Portfolio](https://pushkarshinde.in)
- **Sagar Pradhan**: [GitHub](https://github.com/sagar717-creator)
- **Vighnesh Pingale**: Developer

---

**Last Updated**: April 2026  
**Project Status**: Active Development
