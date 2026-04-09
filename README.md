# 📱 Flutter Absensi GPS

Aplikasi mobile untuk sistem absensi karyawan berbasis GPS menggunakan Flutter dan GetX.

![Flutter](https://img.shields.io/badge/Flutter-3.10.8-blue)
![Dart](https://img.shields.io/badge/Dart-3.0-blue)
![GetX](https://img.shields.io/badge/GetX-4.6.6-purple)
![License](https://img.shields.io/badge/License-Private-red)

## 📋 Table of Contents

- [Fitur](#-fitur)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Documentation](#-documentation)
- [Testing](#-testing)
- [Contributing](#-contributing)

## ✨ Fitur

### 👤 Untuk Karyawan
- ✅ Login dengan email dan password
- ✅ Dashboard dengan informasi absensi
- 📍 Verifikasi lokasi dengan GPS
- 📋 Riwayat absensi
- 👤 Manajemen profil

### 👨‍💼 Untuk Admin
- ✅ Login sebagai admin
- 📊 Dashboard dengan statistik absensi
- 👥 Kelola data karyawan
- 📋 Monitor absensi karyawan
- 📈 Laporan absensi
- ⚙️ Pengaturan sistem

## 📸 Screenshots

> Screenshots akan ditambahkan setelah UI selesai

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10.8
- **Language**: Dart 3.0+
- **State Management**: GetX 4.6.6
- **HTTP Client**: Dio 5.4.0
- **Local Storage**: GetStorage 2.1.1
- **Location**: Geolocator 11.0.0
- **UI Components**: Material Design 3

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.8 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd flutter_absensi_gps
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Quick Test

**Login Credentials (Mock):**
```
Email: admin@test.com (atau email valid lainnya)
Password: 123456 (minimal 6 karakter)
Role: Pilih "Admin" atau "Karyawan"
```

## 📁 Project Structure

```
lib/
├── core/                      # Core utilities & configurations
│   ├── constants/            # App constants (colors, strings, endpoints)
│   ├── theme/               # App theme configuration
│   └── utils/               # Helper utilities & logger
│
├── data/                     # Data layer
│   ├── models/              # Data models
│   ├── providers/           # API providers
│   └── services/            # Services (storage, location)
│
├── modules/                  # Feature modules (GetX pattern)
│   ├── splash/              # Splash screen
│   ├── auth/                # Authentication
│   ├── employee/            # Employee features
│   └── admin/               # Admin features
│
├── routes/                   # App routing
│   ├── app_pages.dart       # Route definitions
│   └── app_routes.dart      # Route constants
│
├── widgets/                  # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── ...
│
└── main.dart                 # App entry point
```

**Untuk struktur lengkap, lihat [STRUCTURE.md](STRUCTURE.md)**

## 📖 Documentation

- **[SUMMARY.md](SUMMARY.md)** - Ringkasan lengkap project
- **[STRUCTURE.md](STRUCTURE.md)** - Penjelasan struktur folder detail
- **[NEXT_STEPS.md](NEXT_STEPS.md)** - Panduan development selanjutnya
- **[QUICK_START.md](QUICK_START.md)** - Quick reference & commands

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 🏗️ Build

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🎯 Development Status

| Module | Status |
|--------|--------|
| Project Setup | ✅ Complete |
| Core Structure | ✅ Complete |
| Authentication | ✅ Complete (Mock) |
| Employee Dashboard | ✅ Complete |
| Admin Dashboard | ✅ Complete |
| Attendance Feature | 🚧 In Progress |
| History | 📝 Planned |
| Employee Management | 📝 Planned |
| Reports | 📝 Planned |

## 📝 TODO

- [ ] Integrate with real API
- [ ] Implement attendance feature (GPS)
- [ ] Implement history page
- [ ] Implement employee management
- [ ] Implement reports
- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Setup CI/CD
- [ ] Add dark mode support

## 🤝 Contributing

Untuk berkontribusi pada project ini:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is private and proprietary.

## 👨‍💻 Author

**Your Name**
- Email: your.email@example.com
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter Team
- GetX Package Contributors
- All open source package contributors

---

**Made with ❤️ using Flutter**ngan

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
