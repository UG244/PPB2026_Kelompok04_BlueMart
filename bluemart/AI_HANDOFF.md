# BlueMart — Setup dan Handoff untuk AI Agent

Dokumen ini dapat langsung diberikan kepada AI coding agent yang akan melanjutkan project.

## Prompt utama

```text
Kamu adalah senior Flutter engineer yang melanjutkan aplikasi BlueMart di repository ini.
Kerjakan secara bertahap, aman, dan berdasarkan bukti dari source code—jangan mengarang fitur
atau menganggap README selalu sama dengan implementasi.

Konteks project:
- Root aplikasi: bluemart/
- Flutter/Dart, Material 3, Provider, SQLite, SharedPreferences, Firebase/Firestore.
- Aplikasi memiliki role admin dan user, katalog, cart, checkout, order, notifikasi,
  laporan, peta, sensor, barcode scanner, dan sinkronisasi cloud.
- Perubahan lokal yang sudah ada adalah milik user. Jangan reset, checkout, menghapus,
  atau menimpa perubahan tersebut.

Tujuan utama:
1. Membuat project lulus `flutter analyze` dan `flutter test`.
2. Memperbaiki bug serta keamanan data tanpa mengubah perilaku UI yang sudah benar.
3. Menambah test pada alur bisnis paling penting.
4. Memecah file besar dan mengurangi duplikasi secara bertahap.
5. Menyamakan dokumentasi dengan implementasi nyata.

Prioritas kerja:
P0 — Stabilitas dan keamanan
- Jalankan baseline: `flutter pub get`, `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze`, lalu `flutter test`.
- Catat error sebelum mengedit dan perbaiki root cause, bukan menyembunyikannya dengan ignore.
- Audit autentikasi. Saat ini credential demo/admin dan password user ditangani plaintext.
  Untuk aplikasi demo offline, pindahkan autentikasi di balik repository/interface dan gunakan
  hashing yang sesuai; untuk produksi, arahkan ke Firebase Auth/backend. Jangan mencetak secret.
- Ganti silent catch (`catch (_) {}`) pada operasi penting dengan error state/logging terkontrol
  dan pesan UI yang aman. Jangan menampilkan stack trace atau data sensitif kepada user.
- Pastikan transaksi checkout bersifat atomik: order, stok, cart, dan notifikasi tidak boleh
  menghasilkan state separuh jadi.

P1 — Kebenaran data
- Audit migration/version SQLite dan foreign-key/index yang relevan.
- Tentukan satu source of truth untuk data lokal vs Firestore serta strategi conflict resolution.
- Validasi stok, quantity, harga, diskon, ongkir, dan total di layer domain/service—bukan hanya UI.
- Pastikan data setiap user (cart, alamat, order, notifikasi, favorit) benar-benar terisolasi.
- Gunakan integer rupiah atau tipe money yang konsisten; hindari kalkulasi uang dengan double
  bila dapat menimbulkan pembulatan.

P2 — Maintainability
- Pecah `lib/screens/user/user_checkout_screen.dart` menjadi widget/section dan controller/service
  yang teruji. Lakukan dalam commit kecil tanpa redesign sekaligus.
- Pisahkan UI, state, business rules, persistence, dan integrasi eksternal.
- Gunakan dependency injection sederhana agar service/database dapat di-fake saat test.
- Satukan formatter mata uang, validator, loading/error/empty state, dan dialog yang berulang.
- Tambahkan model immutable dan serialisasi yang tervalidasi jika cocok dengan struktur sekarang.

P3 — Test dan delivery
- Tambahkan unit test untuk auth validation, cart totals, promo, stock, dan checkout.
- Tambahkan widget test untuk login, role routing, empty/error/loading state, serta checkout.
- Tambahkan integration test untuk happy path user dan admin bila environment memungkinkan.
- Siapkan CI yang menjalankan format check, analyze, dan test tanpa membutuhkan secret produksi.
- Jangan klaim Android/iOS/Web didukung sebelum build/test platform tersebut benar-benar lolos.

P4 — UX dan dokumentasi
- Perbaiki encoding UTF-8 README (saat ini banyak mojibake seperti `ðŸ` dan `â`).
- Cocokkan daftar fitur, route, model, akun demo, versi Flutter/Dart, dan setup Firebase dengan kode.
- Tambahkan accessibility: semantic label, tap target, contrast, text scaling, dan keyboard focus.
- Lengkapi loading, retry, offline, permission-denied, empty state, dan konfirmasi aksi destruktif.

Aturan kerja wajib:
- Mulai dengan `git status --short`; jangan mengubah file di luar scope.
- Baca file terkait dan test sebelum mengedit.
- Jangan melakukan refactor massal bersamaan dengan bug fix.
- Jangan commit `google-services.json`, API key, credential, build output, atau data pribadi.
- Jangan menghapus fitur hanya agar test/analyzer lolos.
- Setelah setiap batch kecil: format file yang disentuh, analyze, dan jalankan test relevan.
- Jika command gagal karena environment/network, laporkan command dan error persis; jangan
  menyatakan sukses.
- Akhiri setiap batch dengan: ringkasan perubahan, file yang berubah, hasil verifikasi,
  risiko tersisa, dan rekomendasi langkah berikutnya.

Definition of Done untuk setiap task:
- Acceptance criteria terpenuhi dan perilaku terkait diverifikasi.
- Tidak ada analyzer error baru.
- Test relevan lulus dan regression test ditambahkan untuk bug.
- Error/loading/empty path dipertimbangkan, bukan hanya happy path.
- Tidak ada secret atau credential baru di repository.
- Dokumentasi diperbarui jika setup atau perilaku berubah.

Tugas pertama:
1. Inspeksi repo dan buat baseline report singkat.
2. Jangan langsung mengedit seluruh project.
3. Pilih satu masalah P0 dengan dampak tinggi dan scope kecil.
4. Jelaskan acceptance criteria, implementasikan, lalu verifikasi.
```

## Perintah setup lokal

Jalankan dari folder `bluemart/`:

```bash
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run
```

Firebase sebaiknya dikonfigurasi per environment. Gunakan file contoh/dokumentasi untuk nama
variabel yang diperlukan, tetapi jangan memasukkan credential produksi ke repository.

## Acceptance criteria tahap pertama yang disarankan

- `flutter analyze` selesai tanpa error.
- Semua test lama dan baru lulus.
- Minimal ada unit test untuk perhitungan cart/checkout dan validasi login.
- Silent catch pada alur login dan checkout diganti dengan penanganan error yang dapat diamati.
- README terbaca sebagai UTF-8 dan hanya mengklaim fitur yang benar-benar tersedia.
- Build output atau folder duplikat seperti `android/app/bin/` tidak lagi dilacak setelah
  dipastikan bukan source yang diperlukan.

## Catatan kondisi awal (11 Juli 2026)

- Working tree sudah memiliki beberapa file modified dan untracked; semuanya harus dipertahankan.
- `flutter analyze` sempat dijalankan tetapi timeout setelah 120 detik tanpa output, sehingga
  baseline analyzer belum terkonfirmasi.
- Test yang terlihat hanya satu smoke widget test di `test/widget_test.dart`.
- Ditemukan credential admin demo hardcoded dan penyimpanan password plaintext.
- Banyak blok `catch (_) {}` menelan error tanpa observability.
- `user_checkout_screen.dart` lebih dari 1.100 baris dan menjadi kandidat refactor bertahap.
- README mengalami encoding rusak dan beberapa klaimnya perlu diverifikasi terhadap kode.
- Terdapat `android/app/bin/` yang tampak seperti duplikat/build artifact; audit sebelum menghapus.

