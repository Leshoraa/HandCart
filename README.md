# HandCart

HandCart adalah aplikasi Android berbasis Flutter untuk merencanakan belanja
berdasarkan toko. Pengguna dapat mengelola toko dan produk, mencatat jumlah
barang serta catatan belanja, menghitung perkiraan total biaya, dan menyimpan
foto produk dari kamera ke penyimpanan lokal aplikasi.

## Tujuan aplikasi

Menyediakan daftar belanja yang terorganisasi per toko, tetap tersedia setelah
aplikasi ditutup, dan dapat digunakan saat berbelanja tanpa bergantung pada
backend atau akun daring.

## Teknologi

- Flutter dan Dart (batas SDK Dart pada `pubspec.yaml`: `^3.13.5`).
- Material 3, tema terang/gelap, dan `dynamic_color`.
- SQLite lokal melalui `sqflite`, dengan `path` dan `path_provider`.
- Kamera/foto melalui `image_picker`.
- State management Flutter bawaan: `ChangeNotifier` dan `InheritedNotifier`.

## Fungsi utama

- **Toko:** melihat, mencari, memfilter berdasarkan kategori, menambah,
  mengedit, menghapus, serta pin/unpin toko.
- **Produk per toko:** melihat dan mencari produk, menambah, mengedit, dan
  menghapus produk.
- **Jumlah belanja:** menambah atau mengurangi jumlah. Produk baru dimulai
  dengan jumlah 1; mengurangi dari 1 mengubah jumlah menjadi 0.
- **Perkiraan biaya:** menghitung dan menampilkan total per toko dari harga
  produk dikalikan jumlahnya. Aplikasi belum menetapkan mata uang tertentu.
- **Catatan:** menyimpan memo/checklist secara terpisah untuk setiap toko.

## Fitur tambahan

- Data contoh awal hanya dimasukkan ketika tabel toko masih kosong; aplikasi
  tidak memasukkan ulang data contoh pada setiap pembukaan.
- Foto produk dapat berasal dari kamera dan ditampilkan kembali dari file lokal.
  Produk contoh juga dapat memakai URL gambar; bila gambar tidak tersedia,
  antarmuka menggunakan ikon fallback.
- Pencarian yang tidak menemukan hasil dibedakan dari daftar yang memang kosong.
- Operasi penyimpanan menampilkan indikator, validasi, dan/atau feedback error
  sesuai alurnya.
- Warna dinamis digunakan bila tersedia; tema terang/gelap tetap memiliki
  fallback.

## Arsitektur aplikasi

Alur utamanya:

1. `main.dart` menjalankan `HandCartApp`.
2. `HandCartApp` membuat dan menginisialisasi `ShoppingPlannerController`.
3. `ShoppingPlannerScope` meneruskan perubahan controller ke widget UI.
4. Controller memuat data melalui `StoreRepository` dan `ProductRepository`,
   lalu memperbarui state setelah operasi repository berhasil.
5. Kedua repository menggunakan `AppDatabase` untuk akses SQLite.

Direktori penting:

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── database/app_database.dart
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
└── features/
    ├── stores/
    │   ├── data/
    │   └── presentation/
    └── shopping_list/
        ├── data/
        │   └── models/presentation/
        ├── services/
        └── state/
```

Komponen utama berada di `lib/features/stores/` dan
`lib/features/shopping_list/`. Controller memakai repository abstrak sehingga
tes dapat mengganti penyimpanan native dengan repository in-memory.

## Implementasi SQLite

Database bernama `handcart.db` dan saat ini menggunakan skema versi 1. Tabel
`stores` menyimpan identitas toko, kategori, deskripsi, ikon, URL gambar,
catatan, tanggal pembuatan, dan status pin. Tabel `products` menyimpan
`store_id`, nama, kategori, harga, deskripsi, ikon, URL/path gambar, dan jumlah.

Relasi produk-ke-toko menggunakan foreign key dengan `ON DELETE CASCADE`.
Foreign key diaktifkan saat database dikonfigurasi. Penghapusan toko menghapus
produk terkait; controller juga menghapus jumlah produk tersebut dari state.
Operasi CRUD dan perubahan jumlah dilakukan secara asynchronous. Data contoh
diinisialisasi dalam transaksi saat tabel toko kosong.

Model toko saat ini mendukung URL gambar, bukan path foto toko lokal. Path foto
lokal hanya didukung oleh model produk.

## Implementasi kamera

`ProductImageService` menggunakan `image_picker` untuk membuka kamera. Foto yang
berhasil diambil disalin ke direktori dokumen aplikasi di dalam folder
`product_images`; path-nya disimpan pada kolom `products.image_path`. Saat editor
produk dibuka kembali, layanan juga mencoba memulihkan hasil kamera Android
yatim (`retrieveLostData`).

Pembatalan kamera menghasilkan `null`, sehingga foto lama tidak diganti.
Kegagalan kamera atau penyalinan file diteruskan ke UI untuk diberi feedback.
File foto lama tidak otomatis dihapus ketika foto diganti atau produknya
dihapus; pembersihan file yatim belum diimplementasikan.

Manifest utama Android menyertakan izin `INTERNET` untuk gambar toko/produk
berbasis URL. Kamera memakai integrasi `image_picker`; belum ada uji kamera
langsung pada perangkat dalam lingkungan pengembangan ini.

## Rancangan UI/UX

- Layar utama memakai kartu toko dua kolom, pencarian, filter kategori, indikator
  pin, serta total rencana belanja.
- Halaman toko memakai daftar produk satu kolom, pencarian, kontrol jumlah,
  catatan toko, dan ringkasan total biaya di bagian bawah.
- Form tambah/edit toko dan produk serta catatan menggunakan bottom sheet agar
  alur utama tetap berada pada halaman terkait.
- Desain menggunakan Material 3, tema terang/gelap, warna dinamis bila tersedia,
  empty state, loading state, dan tampilan error/retry untuk pemuatan awal.

## Pengujian dan hasil validasi

Tes otomatis yang tersedia mencakup controller, pemetaan model produk,
penanganan foto (batal, gagal, dan pemulihan), validasi form produk, penghapusan
produk melalui UI, pembatalan penggantian foto, serta widget daftar toko.

Hasil eksekusi terakhir:

- `flutter analyze` — lulus, tidak ada temuan.
- `flutter test` — lulus, 28 test.
- `flutter build apk --debug` — belum berhasil dijalankan hingga tahap kompilasi:
  Flutter melaporkan Android SDK tidak ditemukan. `ANDROID_HOME`/
  `ANDROID_SDK_ROOT` belum tersedia, dan `adb` tidak ditemukan pada PATH.
- `git diff --check` — lulus.

Tes controller/widget menggunakan repository in-memory. Tes saat ini belum
membuktikan persistensi SQLite melewati restart proses pada perangkat Android.
Build APK dan uji kamera perlu diulang pada komputer/perangkat dengan Android
SDK yang terpasang.

## Cara menjalankan

Pastikan Flutter/Dart sesuai batas SDK proyek dan Android SDK telah dikonfigurasi.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Untuk membuat APK debug:

```powershell
flutter build apk --debug
```

## Audit akhir terhadap rubrik UAS

| Rubrik | Status | Bukti implementasi |
|---|---|---|
| Penyimpanan lokal atau online | Diimplementasikan | SQLite menyimpan toko, produk, jumlah, catatan, status pin, dan path foto produk. Persistensi lintas-restart masih perlu dibuktikan di perangkat. |
| Minimal satu fitur perangkat mobile | Diimplementasikan pada kode | Kamera Android melalui `image_picker`; pengujian langsung di perangkat masih diperlukan. |
| Deskripsi umum dan tujuan | Terdokumentasi | Bagian pengantar dan tujuan dokumen ini. |
| Fungsi utama dan fitur tambahan | Terdokumentasi | Bagian fungsi utama dan fitur tambahan. |
| Rancangan UI/UX | Terdokumentasi | Bagian rancangan UI/UX. |

## Batasan dan pekerjaan lanjutan

- APK debug belum dapat diverifikasi di lingkungan ini karena Android SDK tidak
  tersedia.
- Perlu uji manual pada perangkat Android untuk alur kamera, pemulihan kamera,
  tampilan foto lokal, dan persistensi SQLite setelah aplikasi ditutup/dibuka
  kembali.
- File foto yang sudah tidak direferensikan database belum dibersihkan otomatis.
- Skema SQLite masih versi 1; perubahan skema di masa depan perlu disertai
  migrasi versi.
- Data contoh memakai gambar URL; tampilan gambar daring memerlukan koneksi
  internet.

## Kesimpulan

HandCart telah menghubungkan state aplikasi dengan repository SQLite dan
menyediakan alur foto produk lokal dari kamera. Kode lulus analyzer dan seluruh
tes otomatis yang tersedia, tetapi APK Android dan perilaku pada perangkat
belum dapat diverifikasi sampai Android SDK/perangkat uji tersedia.
