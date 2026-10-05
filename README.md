# 🛒 HandCart

Template awal aplikasi mobile shopping cart & retail assistant berbasis **Flutter** untuk platform **Android** dan **iOS**.

---

## ✨ Fitur Template

- **Material 3 Design**: Dukungan tema Light & Dark Mode yang konsisten dan modern.
- **Clean Feature-First Architecture**: Struktur direktori modular yang memudahkan penambahan fitur baru tanpa refactor besar.
- **Katalog & Filter Produk**:
  - Pencarian interaktif real-time berdasarkan nama & kategori produk.
  - Filter kategori horizontal berbasis *ChoiceChip*.
  - Grid card produk responsif dengan rating dan status harga.
- **Manajemen Keranjang Belanja**:
  - Indikator badge dinamis pada AppBar dan Floating Action Button.
  - Tambah, kurangi kuantitas, dan swipe-to-delete item.
  - Perhitungan otomatis Subtotal, PPN (11%), dan Total pembayaran.
  - Dialog konfirmasi pengosongan keranjang dan flow checkout.
- **State Management Ringan**: Menggunakan `ChangeNotifier` + `InheritedNotifier` bawaan (`CartScope`), siap dialihkan ke Riverpod atau Bloc jika dibutuhkan di kemudian hari.
- **Multiplatform Ready**: Konfigurasi lengkap native Android (Kotlin / Gradle 8+) dan iOS (Swift).

---

## 📁 Struktur Direktori

```text
lib/
├── main.dart                          # Entry point aplikasi & status bar styling
├── app.dart                           # Root MaterialApp, konfigurasi tema & CartScope
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Palet warna brand & semantic colors
│   │   ├── app_dimens.dart            # Dimensi padding, radius & spacing
│   │   └── app_strings.dart           # Teks antarmuka dan label aplikasi
│   ├── theme/
│   │   └── app_theme.dart             # Konfigurasi ThemeData (Light & Dark)
│   ├── utils/
│   │   └── currency_formatter.dart    # Formatter mata uang Rupiah (Rp)
│   └── widgets/
│       ├── custom_button.dart         # Tombol kustom reusable
│       └── empty_state_view.dart      # View untuk state kosong
└── features/
    ├── home/
    │   ├── data/
    │   │   ├── dummy_data.dart        # Mock data kategori & produk
    │   │   └── models/
    │   │       └── product_model.dart # Model data Product
    │   └── presentation/
    │       ├── pages/
    │       │   └── home_page.dart     # Halaman utama katalog
    │       └── widgets/
    │           └── product_card.dart  # Kartu item produk
    └── cart/
        ├── presentation/
        │   ├── pages/
        │   │   └── cart_page.dart     # Halaman ringkasan keranjang & checkout
        │   └── widgets/
        │       └── cart_item_tile.dart# Komponen item keranjang
        └── state/
            ├── cart_controller.dart   # Logika bisnis keranjang belanja
            └── cart_scope.dart        # InheritedNotifier provider
```

---

## 🚀 Cara Menjalankan

### 1. Prasyarat Lingkungan
Pastikan Flutter dan Android SDK sudah masuk ke PATH terminal Anda. Variabel environment sudah dikonfigurasi di `~/.zshrc`:
```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$HOME/.local/share/flutter/bin:/opt/android-studio/jbr/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
```

### 2. Mengambil Dependensi
```bash
flutter pub get
```

### 3. Menjalankan Aplikasi
- Pada perangkat atau emulator Android:
  ```bash
  flutter run
  ```
- Memilih device tertentu:
  ```bash
  flutter devices
  flutter run -d <device_id>
  ```

### 4. Menjalankan Pengujian (Testing) & Analisis
```bash
flutter analyze
flutter test
```

### 5. Build Package
- **Android APK (Debug/Release)**:
  ```bash
  flutter build apk --debug
  flutter build apk --release
  ```
- **Android App Bundle (Play Store)**:
  ```bash
  flutter build appbundle
  ```
- **iOS (di macOS)**:
  ```bash
  flutter build ios
  ```
