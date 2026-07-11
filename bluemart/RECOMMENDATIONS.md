# 🔄 BlueMart — Technician Handoff & Recommendations

> **Dokumen ini** berisi temuan audit, prioritas perbaikan, dan rekomendasi teknis untuk pengembangan selanjutnya.

---

## 📋 Ringkasan Status Saat Ini

| Area | Status |
|---|---|
| **Autentikasi** | ✅ Password di-hash (CryptoUtils.sha256 + salt), admin di-seed otomatis |
| **Provider Pattern** | ✅ AuthProvider, ProductProvider, NotificationProvider, CartService |
| **Route Guards** | ✅ `/admin-*` hanya admin, `/user-*` hanya user login |
| **Material Design 3** | ✅ AppTheme.lightTheme terpusat |
| **Notifikasi** | ✅ Checkout success, admin status update, SharedPrefs persistence |
| **Debounce Search** | ✅ 300ms Timer di home screen |
| **Swipe-to-Delete** | ✅ Dismissible di cart & notifikasi |
| **Keyboard Dismiss** | ✅ GestureDetector di semua form screen |
| **Password Hashing** | ✅ crypto_utils.dart (non-reversible hash + salt) |
| **Admin User Management** | ✅ CRUD user + ubah role (admin/editor/viewer/user) |

---

## 🔴 P0 — Critical (Segera Diperbaiki)

### 1. Database — Transaksi Atomik & Stok
**File**: `lib/services/transaction_service.dart`, `lib/database/db_helper.dart`
- ✅ Saat ini sudah menggunakan `db.transaction()` di `TransactionService.checkout()`
- ⚠️ **Perlu dipastikan**: rollback berfungsi jika stok tidak cukup
- ⚠️ **Migration path**: versi database saat ini v3 — jika ada perubahan schema, bump version dan tambah `onUpgrade` handler

### 2. Error Handling — Ganti `catch (_) {}`
**File**: semua `services/`, `providers/`, dan `screens/`
- ✅ `auth_service.dart` sudah pakai `debugPrint` untuk logging
- ⚠️ **Tersisa**: beberapa file masih pakai `catch (_) {}` kosong
- **Action**: audit semua file dan tambahkan minimal `debugPrint('Module.error: $e\n$st')`

### 3. Password — Hapus Hardcode
**File**: `lib/services/auth_service.dart`
- ✅ Admin password disimpan sebagai hash di SharedPreferences
- ✅ Admin di-seed otomatis via `_seedAdminIfNeeded()`
- ✅ Password diverifikasi melalui `CryptoUtils.verifyPassword()`
- ⚠️ **Default password masih hardcoded** (`_defaultAdminPass = 'admin123'`) — di production, gunakan environment variable

---

## 🟠 P1 — High Priority

### 4. Checkout Screen — Refactor
**File**: `lib/screens/user/user_checkout_screen.dart`
- Saat ini **1,330+ baris** — perlu dipisah ke widget terpisah
- **Action**: extract `_AddressCard`, `_ShippingCard`, payment instructions ke `widgets/` folder

### 5. README — Update Klaim
**File**: `README.md`
- ⚠️ Beberapa klaim package (seperti `google_fonts`, `flutter_svg`, `cached_network_image`, `fl_chart`) **tidak ada** di `pubspec.yaml`
- ⚠️ Akun demo (`user1`/`user123`, `user2`/`user123`) **tidak ada** — cuma admin yang di-seed
- ⚠️ Skema database di README **tidak cocok** dengan schema aktual di `db_helper.dart`

### 6. Repository Hygiene — Duplikat Folder
- ⚠️ Ada folder `bluemart/bluemart/` yang merupakan artifact build
- **Action**: hapus atau tambahkan ke `.gitignore`

---

## 🟡 P2 — Medium Priority

### 7. Testing — Unit & Widget Tests
**File**: `test/widget_test.dart`
- Hanya ada 1 smoke test (`'Counter increments smoke test'`)
- **Action**: tambahkan minimal:
  - Unit test untuk `CryptoUtils`
  - Unit test untuk `AuthService.login/register`
  - Widget test untuk `LoginScreen`

### 8. CI/CD — GitHub Actions
**File**: `.github/workflows/` (belum ada)
- **Action**: buat workflow yang menjalankan `dart format --check`, `dart analyze`, `flutter test`

### 9. Firestore Sync — Audit
**File**: `lib/services/firestore_service.dart`
- Sinkronisasi Firestore sudah ada di `TransactionService.checkout()` tapi hanya push
- Belum ada pull/offline-first architecture yang dijanjikan di README

---

## 🟢 P3 — Low Priority

### 10. Accessibility
- Belum ada `Semantics` widget atau `semanticLabel` di komponen UI

### 11. Offline State
- Belum ada indikator koneksi (misal: "No Internet" banner)

### 12. Deep Link / Push Notification
- Firebase Cloud Messaging belum diimplementasi
- Notifikasi hanya local via SharedPreferences

---

## 📁 Struktur Direktori Saat Ini

```
bluemart/lib/
├── main.dart                          # Entry point, MultiProvider, Route Guards
├── database/
│   └── db_helper.dart                 # SQLite singleton, migration v3
├── models/
│   ├── app_user.dart                  # User model
│   ├── cart_item.dart                 # Cart item model
│   ├── checkout_address.dart          # Address model
│   ├── notification_item.dart         # Notification model (icon string-based)
│   ├── product.dart                   # Product model
│   └── supplier.dart                  # Supplier model + sample data
├── providers/
│   ├── auth_provider.dart             # Auth state + route guards
│   ├── notification_provider.dart     # Notification state + SharedPrefs
│   └── product_provider.dart          # Product state
├── screens/
│   ├── login_screen.dart              # Login/Register with form validation
│   ├── map_screen.dart                # OpenStreetMap with flutter_map
│   ├── profile_screen.dart            # Profile + settings + FAQ
│   ├── admin/
│   │   ├── admin_coupon_screen.dart   # CRUD promo codes
│   │   ├── admin_dashboard_screen.dart# Main admin dashboard
│   │   ├── admin_payment_screen.dart  # Payment method toggle
│   │   ├── admin_product_form_screen.dart # Product CRUD form
│   │   ├── admin_product_list_screen.dart # Product list
│   │   ├── admin_qris_screen.dart     # QRIS nominal setter
│   │   ├── admin_sales_report_screen.dart # Sales report + status update
│   │   └── admin_user_management_screen.dart # User CRUD + role management
│   └── user/
│       ├── barcode_scanner_screen.dart # Barcode scanner (mobile_scanner)
│       ├── user_address_screen.dart    # Address picker
│       ├── user_cart_screen.dart       # Cart with swipe-to-delete
│       ├── user_checkout_screen.dart   # Checkout (payment, shipping, promo)
│       ├── user_favorite_screen.dart   # Wishlist
│       ├── user_home_screen.dart       # Home: banner, categories, grid
│       ├── user_main_screen.dart       # Bottom nav shell
│       ├── user_notification_screen.dart # Notification list with tabs
│       ├── user_order_history_screen.dart # Order history + timeline
│       └── user_product_detail_screen.dart # Product detail + add to cart
├── services/
│   ├── api_service.dart               # External API calls
│   ├── auth_service.dart              # Auth with hashed passwords
│   ├── cart_service.dart              # Cart state (ChangeNotifier)
│   ├── firestore_service.dart         # Firestore cloud sync
│   ├── image_service.dart             # Image picker service
│   ├── location_service.dart          # GPS service
│   ├── product_service.dart           # Product CRUD service
│   ├── sensor_service.dart            # Compass/magnetometer service
│   └── transaction_service.dart       # Atomic transaction checkout
├── theme/
│   └── app_theme.dart                 # Material Design 3, colors, radii, shadows
├── utils/
│   ├── constants.dart                 # App-wide constants
│   └── crypto_utils.dart              # Password hashing utility
└── widgets/
    ├── compass_widget.dart            # Compass UI widget
    └── product_card.dart              # Reusable product card
```

---

## 🚀 Setup & Run

```bash
cd bluemart
flutter pub get
flutter run
```

### Verifikasi Kualitas Kode

```bash
# Format check
dart format --set-exit-if-changed lib/

# Static analysis
dart analyze lib/

# Run tests
flutter test
```

---

## ✅ Definition of Done

- [x] `dart analyze lib/` passes with **0 errors, 0 warnings**
- [x] All routes guarded (`/admin-*` admin-only, `/user-*` login-required)
- [x] Password hashing with salt via `CryptoUtils`
- [x] Atomic transactions for checkout via `db.transaction()`
- [x] Consistent UI (AppTheme + keyboard dismiss + SafeArea on all screens)
- [ ] Unit tests for core logic
- [ ] CI/CD pipeline
- [ ] Database migration path
- [ ] README accurate

---

## 📌 Acceptance Criteria

1. **Login berhasil** dengan admin (username: `admin`, password: `admin123`)
2. **Register user baru** dan login dengan user tersebut
3. **Browse & search produk**, tambah ke cart, checkout
4. **Notifikasi muncul** setelah checkout sukses
5. **Admin bisa** lihat daftar user, tambah user, ubah role, hapus user
6. **Admin bisa** ubah status pesanan dan user mendapat notifikasi
7. **Tidak ada crash** saat navigasi antar screen
8. **Keyboard tertutup** saat tap di luar input field

---

## 📝 Catatan Kondisi Awal

- Database menggunakan SQLite dengan path `bluemart.db` di device lokal
- Admin account di-seed otomatis pada login pertama
- Notifikasi disimpan di SharedPreferences (key: `user_notifications`)
- Semua user terdaftar disimpan di SharedPreferences (key: `registered_users`)
- Firestore sync bersifat non-kritis (gagal sync tidak memblokir operasi)

---

**Dokumen ini dibuat pada**: 11 Juli 2026
**Versi aplikasi**: 1.0.0+1
**Flutter SDK**: ^3.12.2