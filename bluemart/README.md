# BlueMart

**Aplikasi Retail UMKM - Project Akhir Pemrograman Piranti Bergerak**

---

## Identitas Project

| Item | Detail |
|------|--------|
| Nama Aplikasi | BlueMart |
| Nama Kelompok | Kelompok 04 |
| Mata Kuliah | Pemrograman Piranti Bergerak (TI253311) |
| Program Studi | Teknologi Informasi |
| Semester | IV |

---

## Deskripsi

BlueMart adalah aplikasi mobile untuk manajemen toko retail UMKM yang memungkinkan pemilik toko (Admin) mengelola produk, inventaris, dan penjualan, serta pembeli (User) dapat melihat produk, berbelanja, dan melihat riwayat pesanan. Aplikasi ini dibangun menggunakan Flutter dengan platform target Android.

---

## Permasalahan

UMKM retail seringkali kesulitan dalam:
1. Mengelola inventaris produk secara digital dan terpusat
2. Mengontrol visibilitas produk yang ditampilkan ke pembeli
3. Mencatat transaksi penjualan secara otomatis
4. Memantau stok barang yang menipis
5. Mendapatkan laporan penjualan yang akurat
6. Mengelola data dari berbagai perangkat secara cloud

---

## Solusi

BlueMart menyediakan solusi mobile dengan dua peran (Admin dan User):

**Admin (Pemilik/Karyawan Toko):**
- Manajemen produk lengkap (CRUD) dengan SQLite
- Kontrol visibilitas produk (publish/draft)
- Dashboard ringkasan stok dan produk
- Laporan penjualan dengan filter tanggal
- Integrasi Firestore untuk sinkronisasi cloud

**User (Pembeli):**
- Melihat produk aktif (hanya yang di-publish admin)
- Filter dan pencarian produk
- Keranjang belanja dengan manajemen kuantitas
- Checkout dengan pengurangan stok atomik (SQL transaction)
- Riwayat pesanan pribadi

**Fitur Teknologi:**
- Login dengan role-based session (SharedPreferences)
- Kamera untuk foto produk
- Peta OpenStreetMap dengan lokasi supplier
- Sensor kompas (magnetometer) untuk navigasi ke supplier terdekat
- API eksternal (kurs mata uang)
- Cloud database (Firestore)

---

## Fitur

| No | Fitur | Deskripsi |
|----|-------|-----------|
| F1 | Role-based Login & Session | Login dengan dua peran (admin/user), session persist dengan SharedPreferences, route guarding |
| F2 | Product CRUD (SQLite) | Create, Read, Update, Delete produk dengan validasi, empty state, swipe-to-delete |
| F3 | Admin Dashboard | Ringkasan total produk, stok, stok menipis, aksi cepat |
| F4 | Kamera | Ambil foto dari kamera/gallery untuk produk, simpan di direktori lokal |
| F5 | Peta & Lokasi | OpenStreetMap, marker user dan supplier, info card, recenter |
| F6 | Sensor Kompas | Magnetometer, bearing ke supplier terdekat, panah rotasi, fallback |
| F7 | API Eksternal | Kurs mata uang (exchangerate-api.com), cache session, loading/error state |
| F8 | Cloud Database (Firestore) | Push/pull sinkronisasi, reconcile by timestamp, sync indicator |
| F9 | Product Visibility Control | Admin mengontrol publish/draft produk, filter All/Active/Draft |
| F10 | Shopping Cart & Checkout | Keranjang, quantity stepper, atomic checkout (SQL transaction), snapshot harga |
| F11 | Order History & Sales Report | Riwayat pesanan user, laporan penjualan admin dengan date range filter |

---

## Teknologi

| Teknologi | Kegunaan |
|-----------|----------|
| Flutter | Framework aplikasi mobile |
| Dart | Bahasa pemrograman |
| SQLite (sqflite) | Database lokal |
| SharedPreferences | Session/login persist |
| Provider | State management (cart) |
| image_picker | Kamera & galeri |
| path_provider | Direktori penyimpanan file |
| flutter_map | OpenStreetMap |
| latlong2 | Koordinat geografis |
| geolocator | Lokasi pengguna |
| sensors_plus | Sensor magnetometer |
| http | HTTP client untuk API |
| firebase_core | Firebase initialization |
| cloud_firestore | Cloud Firestore database |
| permission_handler | Izin kamera & lokasi |

---

## Cara Instalasi

### Prasyarat
- Flutter SDK (versi ^3.12.2 atau lebih baru)
- Android Studio / VS Code
- Emulator atau perangkat Android

### Langkah-langkah

1. **Clone repository**
   ```bash
   git clone https://github.com/UG244/a.git
   cd bluemart
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase (untuk fitur cloud sync)**
   - Buat project Firebase di [Firebase Console](https://console.firebase.google.com)
   - Register Android app dengan package name `com.example.bluemart`
   - Download `google-services.json` dan letakkan di `android/app/`
   - Jalankan `flutterfire configure` jika menggunakan FlutterFire CLI

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

### Akun Demo

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | Admin |
| user1 | user123 | User |
| user2 | user123 | User |

---

## Pembagian Tugas

| Nama | NIM | Tanggung Jawab |
|------|-----|----------------|
| [Anggota 1] | [NIM] | [Fitur yang dikerjakan] |
| [Anggota 2] | [NIM] | [Fitur yang dikerjakan] |
| [Anggota 3] | [NIM] | [Fitur yang dikerjakan] |

*(Diisi sesuai kontribusi masing-masing anggota)*

---

## Struktur Project

```
lib/
├── main.dart
├── utils/
│   └── constants.dart
├── models/
│   ├── app_user.dart
│   ├── product.dart
│   ├── supplier.dart
│   └── cart_item.dart
├── database/
│   └── db_helper.dart
├── services/
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── cart_service.dart
│   ├── transaction_service.dart
│   ├── image_service.dart
│   ├── location_service.dart
│   ├── sensor_service.dart
│   ├── api_service.dart
│   └── firestore_service.dart
├── screens/
│   ├── login_screen.dart
│   ├── profile_screen.dart
│   ├── map_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_product_list_screen.dart
│   │   ├── admin_product_form_screen.dart
│   │   └── admin_sales_report_screen.dart
│   └── user/
│       ├── user_home_screen.dart
│       ├── user_cart_screen.dart
│       ├── user_checkout_screen.dart
│       └── user_order_history_screen.dart
└── widgets/
    ├── product_card.dart
    └── compass_widget.dart
```

---

## Catatan

- Aplikasi menggunakan kredensial hardcoded untuk keperluan perkuliahan (tidak ada backend autentikasi nyata)
- Data supplier bersifat statis (hardcoded) untuk keperluan demo fitur peta
- API eksternal menggunakan exchangerate-api.com (gratis, tanpa API key)
- Fitur Firestore memerlukan setup Firebase manual (lihat Cara Instalasi)