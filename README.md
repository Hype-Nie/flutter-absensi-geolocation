# 📱 Flutter Absensi GPS

Aplikasi mobile untuk sistem absensi karyawan berbasis GPS dan foto selfie menggunakan Flutter dan GetX. Dibangun dengan keamanan berlapis untuk mencegah pemalsuan absensi.

![Flutter](https://img.shields.io/badge/Flutter-3.10.8+-blue)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue)
![GetX](https://img.shields.io/badge/GetX-4.6.6-purple)
![License](https://img.shields.io/badge/License-Private-red)

## 📋 Table of Contents

- [Fitur](#-fitur)
- [Alur Aplikasi](#-alur-aplikasi)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Testing](#-testing)
- [Build](#-build)
- [Development Status](#-development-status)
- [Contributing](#-contributing)

## ✨ Fitur

### 👤 Untuk Karyawan
- ✅ Login dengan NPK (Nomor Pokok Karyawan) dan password
- ✅ Dashboard dengan statistik absensi (hadir, izin, sakit) dan riwayat terkini
- ✅ Validasi lokasi GPS sebelum absensi (radius 200 meter dari titik lokasi yang telah ditentukan)
- ✅ Ambil foto selfie saat absensi
- ✅ Clock-in dan Clock-out (clock-out hanya bisa setelah jam 09:00)
- ✅ Riwayat absensi lengkap dengan filter status dan pagination
- ✅ Halaman sukses absensi dengan detail waktu dan lokasi

### 👨‍💼 Untuk Admin
- ✅ Login sebagai admin
- ✅ Dashboard dengan statistik absensi harian (hadir, izin, sakit, terlambat)
- ✅ Daftar absensi hari ini dengan status karyawan
- ✅ Detail absensi karyawan (foto clock-in dan clock-out, koordinat GPS)
- ✅ Manajemen data karyawan (tambah, edit, hapus, lihat detail)
- ✅ Laporan absensi bulanan dengan ekspor ke CSV dan PDF

### 🔒 Fitur Keamanan (Anti-Spoofing)
- ✅ Deteksi emulator/simulator
- ✅ Deteksi perangkat rooted/jailbroken
- ✅ Deteksi mock location (lokasi palsu)
- ✅ Sinkronisasi waktu via NTP (mencegah manipulasi waktu perangkat)
- ✅ Deteksi pergerakan tidak wajar (kecepatan > 180 km/h)
- ✅ Deteksi mode debug pada build release

## 🔄 Alur Aplikasi

### Alur Karyawan
```
Splash Screen
    │
    ├── Sudah Login → Dashboard Karyawan
    │       │
    │       ├── Tombol "Masuk" → GPS Validation
    │       │       │
    │       │       ├── Security Check (emulator, root, mock GPS, NTP, movement)
    │       │       │       ├── Gagal → Dialog peringatan, absensi ditolak
    │       │       │       └── Lolos → Validasi jarak ke titik lokasi
    │       │       │
    │       │       ├── Dalam radius (≤200m) → Submit absensi → Halaman Sukses
    │       │       └── Di luar radius → Dialog konfirmasi → Submit (status: menunggu_konfirmasi)
    │       │
    │       ├── Tombol "Keluar" → GPS Validation (clock-out, setelah jam 09:00)
    │       │
    │       └── Riwayat → History Page (filter, pagination)
    │
    └── Belum Login → Login Page → Dashboard (sesuai role)
```

### Alur Admin
```
Login → Dashboard Admin
    ├── Tab Dashboard: Statistik harian + daftar absensi → Detail Absensi (foto, GPS)
    ├── Tab Karyawan: Daftar karyawan → Detail / Tambah / Edit Karyawan
    └── Tab Laporan: Laporan bulanan → Ekspor CSV/PDF
```

## 🛠️ Tech Stack

| Kategori | Package | Versi |
|----------|---------|-------|
| Framework | Flutter | 3.10.8+ |
| Language | Dart | 3.0+ |
| State Management | GetX | 4.6.6 |
| HTTP Client | Dio | 5.4.0 |
| HTTP Client (alternatif) | http | 1.2.0 |
| Local Storage | GetStorage | 2.1.1 |
| Local Storage | SharedPreferences | 2.2.2 |
| Location | Geolocator | 11.0.0 |
| Maps | flutter_map + latlong2 | 8.2.2 / 0.9.1 |
| Maps (opsional) | google_maps_flutter | 2.5.3 |
| Camera | Camera | 0.11.0+1 |
| Image Picker | image_picker | 1.0.7 |
| Permission | permission_handler | 11.2.0 |
| NTP Time Sync | ntp | 2.0.0 |
| Device Info | device_info_plus | 10.1.0 |
| Root/Jailbreak Detection | jailbreak_root_detection | 1.2.0 |
| Loading UI | flutter_easyloading | 3.0.5 |
| SVG | flutter_svg | 2.0.10+1 |
| Image Cache | cached_network_image | 3.3.1 |
| Localization | intl | 0.19.0 |
| Logging | logger | 2.0.2+1 |
| Env Config | flutter_dotenv | 5.1.0 |
| Share | share_plus | 7.2.1 |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.8 atau lebih tinggi
- Dart SDK 3.0 atau lebih tinggi
- Android Studio / VS Code
- Android SDK / Xcode (untuk iOS)

### Installation

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd flutter-absensi-geolocation
   ```

2. **Buat file konfigurasi `.env`**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` dan isi URL backend API:
   ```env
   BASE_URL=https://api-laravel.hftech.web.id/api
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

### Login

Gunakan NPK (Nomor Pokok Karyawan) dan password yang terdaftar di backend.

| Field | Keterangan |
|-------|-----------|
| NPK | Nomor Pokok Karyawan (wajib diisi) |
| Password | Minimal 6 karakter |

> Role (admin/karyawan) ditentukan otomatis dari respons API.

### Konfigurasi Titik Lokasi

Titik-titik lokasi valid untuk absensi dikonfigurasi di `lib/modules/employee/gps_validation/controllers/gps_validation_controller.dart`:

```dart
final List<LocationPoint> validationPoints = const [
  LocationPoint(name: 'Lokasi 1', position: LatLng(-7.15162, 111.60486)),
  // ... tambahkan koordinat lokasi kantor
];
```

Radius validasi default: **200 meter**.

## 📁 Project Structure

```
lib/
├── core/                          # Core utilities & konfigurasi
│   ├── constants/                # Konstanta aplikasi
│   │   ├── app_assets.dart       # Path asset
│   │   ├── app_colors.dart       # Warna aplikasi
│   │   ├── app_endpoints.dart    # Endpoint API
│   │   └── app_strings.dart      # String UI
│   ├── services/
│   │   └── security_service.dart # Layanan keamanan anti-spoofing
│   ├── theme/
│   │   └── app_theme.dart        # Tema Material Design
│   ├── utils/
│   │   ├── helpers.dart          # Helper functions
│   │   └── logger.dart           # Logger
│   └── widgets/
│       └── app_footer.dart       # Widget footer
│
├── data/                          # Data layer
│   ├── models/                   # Model data
│   │   ├── attendance_history_model.dart
│   │   ├── attendance_model.dart
│   │   ├── dashboard_attendance_model.dart
│   │   ├── employee_model.dart
│   │   ├── paginated_users_response.dart
│   │   ├── report_model.dart
│   │   ├── user_model.dart
│   │   └── user_stats_model.dart
│   ├── providers/
│   │   └── api_provider.dart     # HTTP client (Dio)
│   └── services/
│       ├── attendance_service.dart  # Layanan absensi (clock-in/out, riwayat, ekspor)
│       ├── auth_service.dart        # Layanan autentikasi
│       ├── employee_service.dart    # Layanan manajemen karyawan
│       ├── location_service.dart    # Layanan GPS
│       └── storage_service.dart     # Layanan penyimpanan lokal
│
├── modules/                       # Modul fitur (pola GetX: view/controller/binding)
│   ├── splash/                   # Splash screen + routing awal
│   ├── auth/
│   │   └── login/                # Halaman login (NPK + password)
│   ├── employee/
│   │   ├── dashboard/            # Dashboard karyawan (statistik + riwayat terkini)
│   │   ├── gps_validation/       # Validasi GPS + security check + submit absensi
│   │   ├── photo_validation/     # Ambil foto selfie + submit absensi
│   │   ├── attendance_success/   # Halaman sukses absensi
│   │   └── history/              # Riwayat absensi lengkap (filter + pagination)
│   └── admin/
│       ├── dashboard/            # Dashboard admin (statistik harian + daftar absensi)
│       ├── attendance_detail/    # Detail absensi karyawan (foto + koordinat GPS)
│       ├── employees/            # Daftar karyawan
│       ├── employee_detail/      # Detail karyawan
│       ├── employee_form/        # Form tambah/edit karyawan
│       └── reports/              # Laporan bulanan + ekspor CSV/PDF
│
├── routes/
│   ├── app_pages.dart            # Definisi semua route
│   └── app_routes.dart           # Konstanta nama route
│
├── widgets/                       # Widget reusable
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── empty_state.dart
│   ├── loading_widget.dart
│   └── widgets.dart
│
└── main.dart                      # Entry point aplikasi
```

## 🧪 Testing

```bash
# Jalankan semua test
flutter test

# Jalankan test tertentu
flutter test test/widget_test.dart

# Jalankan dengan coverage
flutter test --coverage
```

## 🏗️ Build

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (untuk Play Store)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🎯 Development Status

| Modul | Status |
|-------|--------|
| Setup & Konfigurasi | ✅ Selesai |
| Arsitektur & Core | ✅ Selesai |
| Autentikasi (Login/Logout) | ✅ Selesai |
| Dashboard Karyawan | ✅ Selesai |
| Validasi GPS + Security | ✅ Selesai |
| Foto Selfie (Photo Validation) | ✅ Selesai |
| Clock-in / Clock-out | ✅ Selesai |
| Riwayat Absensi | ✅ Selesai |
| Dashboard Admin | ✅ Selesai |
| Detail Absensi (Admin) | ✅ Selesai |
| Manajemen Karyawan (Admin) | ✅ Selesai |
| Laporan & Ekspor CSV/PDF | ✅ Selesai |
| Fitur Keamanan (Anti-Spoofing) | ✅ Selesai |

## 🌐 Backend API

Aplikasi ini terhubung ke REST API Laravel. URL dikonfigurasi via file `.env`:

```env
BASE_URL=https://api-laravel.hftech.web.id/api
```

Endpoint utama yang digunakan:

| Endpoint | Keterangan |
|----------|-----------|
| `POST /login` | Login dengan NPK dan password |
| `POST /logout` | Logout |
| `POST /absensi/clock-in` | Clock-in (multipart/form-data) |
| `POST /absensi/clock-out` | Clock-out (multipart/form-data) |
| `GET /attendance/history` | Riwayat absensi per karyawan |
| `GET /attendance/daily` | Data absensi harian (admin) |
| `GET /employees` | Daftar karyawan (admin) |
| `POST /employees/create` | Tambah karyawan (admin) |
| `PUT /employees/update` | Update karyawan (admin) |
| `DELETE /employees/delete` | Hapus karyawan (admin) |
| `GET /reports/monthly` | Laporan bulanan (admin) |
| `GET /reports/export` | Ekspor laporan CSV/PDF (admin) |

## 🤝 Contributing

Untuk berkontribusi pada project ini:

1. Fork the project
2. Buat feature branch (`git checkout -b feature/NamaFitur`)
3. Commit perubahan (`git commit -m 'Add: deskripsi fitur'`)
4. Push ke branch (`git push origin feature/NamaFitur`)
5. Buat Pull Request

## 📄 License

Project ini bersifat privat dan proprietary.

---

**Made with ❤️ using Flutter**
