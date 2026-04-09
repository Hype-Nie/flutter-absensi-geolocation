# Assets Folder

Folder ini digunakan untuk menyimpan asset aplikasi seperti gambar, icon, dan animasi.

## Struktur

```
assets/
├── images/          # Gambar dan foto
│   ├── logo.png
│   ├── placeholder.png
│   └── no_data.png
│
├── icons/           # Icon SVG
│   ├── attendance.svg
│   ├── employee.svg
│   ├── dashboard.svg
│   └── profile.svg
│
└── animations/      # Lottie animations (jika diperlukan)
    ├── loading.json
    ├── success.json
    └── error.json
```

## Cara Menambah Assets

1. Letakkan file di folder yang sesuai
2. Update `pubspec.yaml` di bagian assets
3. Gunakan konstanta dari `lib/core/constants/app_assets.dart`

## Format yang Disarankan

- **Images**: PNG, JPG (untuk foto dan gambar)
- **Icons**: SVG (untuk icon yang scalable)
- **Animations**: JSON (Lottie animations)
