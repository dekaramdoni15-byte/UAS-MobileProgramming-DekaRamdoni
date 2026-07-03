# UAS Mobile Programming — Aplikasi Katalog Produk

Aplikasi katalog produk dengan Login/Register (Firebase Auth), REST API (Node.js),
dan koneksi mobile-ke-server via IP Address dalam satu jaringan WiFi.

## Struktur Folder

```
UAS_MobileProgramming/
├── backend/              -> Server Node.js (REST API)
│   ├── server.js
│   ├── package.json
│   └── products.json     -> "database" sederhana (auto-generate/terupdate)
└── mobile_app/            -> Project Flutter
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── models/
        │   └── product.dart
        ├── services/
        │   ├── auth_service.dart
        │   └── product_service.dart
        └── screens/
            ├── login_screen.dart
            ├── register_screen.dart
            ├── home_screen.dart
            ├── product_list_screen.dart
            └── product_form_screen.dart
```

## Mapping ke Soal UAS

| Soal | Implementasi |
|---|---|
| No. 1 - Firebase Auth (Login/Register) | `login_screen.dart`, `register_screen.dart`, `auth_service.dart` |
| No. 2 - REST API CRUD | `backend/server.js` (server) + `product_service.dart` (client) |
| No. 3 - Gabungan + Navigator + IP Address | `main.dart` (AuthWrapper) → `home_screen.dart` → `product_list_screen.dart`, semua pindah halaman pakai `Navigator` |

## Mapping ke 6 Materi Setelah UTS

| Materi | Lokasi di kode |
|---|---|
| 1. Firebase Authentication | `auth_service.dart`, `login_screen.dart`, `register_screen.dart` |
| 2. REST API / HTTP Integration | `server.js`, `product_service.dart` |
| 3. Navigator | Perpindahan Login → Register, Home → Form Tambah/Edit |
| 4. TabLayout & ViewPage | `home_screen.dart` (TabBar: Produk & Profil) |
| 5. Context Menu | `product_list_screen.dart` (PopupMenuButton Edit/Hapus) |
| 6. ListView | `product_list_screen.dart` (ListView.builder) |

Materi tambahan (Autocomplete, Date Picker, Audio/Video Player) bisa kalian
tambahkan sendiri kalau ingin menambah variasi/nilai — misalnya Date Picker
untuk field "tanggal masuk stok".

---

## Langkah Setup

### 1. Jalankan Backend (Node.js)

```bash
cd backend
npm install
npm start
```

Server akan berjalan di `http://0.0.0.0:3000`. Cek IP address laptop kamu:

- **Windows**: buka Command Prompt, ketik `ipconfig`, lihat bagian **IPv4 Address**
  (contoh: `192.168.1.10`)
- **Mac/Linux**: buka Terminal, ketik `ifconfig` atau `ip addr`

Pastikan laptop dan HP/emulator terhubung ke **WiFi yang sama**.

Test dulu di browser laptop: `http://localhost:3000/api/products`
Lalu test dari HP (browser HP): `http://<IP_LAPTOP>:3000/api/products`
Kalau muncul data JSON, berarti koneksi jaringan sudah benar.

### 2. Setup Firebase

1. Buka [Firebase Console](https://console.firebase.google.com), buat project baru.
2. Aktifkan **Authentication** → Sign-in method → **Email/Password**.
3. Install FlutterFire CLI (sekali saja):
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Di dalam folder `mobile_app`, jalankan:
   ```bash
   flutterfire configure
   ```
   Ini akan otomatis membuat file `lib/firebase_options.dart` dan
   menghubungkan project Flutter kalian ke Firebase project yang dipilih.

### 3. Ganti IP Address di Flutter

Buka `mobile_app/lib/services/product_service.dart`, ganti baris:

```dart
static const String baseUrl = "http://192.168.1.10:3000/api/products";
```

dengan IP laptop kamu yang sebenarnya (dari langkah 1).

### 4. Install dependencies & Jalankan Flutter App

```bash
cd mobile_app
flutter pub get
flutter run
```

Pilih device (Chrome/emulator/HP fisik yang terhubung USB debugging & WiFi sama).

---

## Alur Aplikasi

1. Buka app → **Login Screen**. Belum punya akun? Tekan "Register".
2. Setelah Register/Login berhasil → otomatis masuk ke **Home Screen**.
3. Home Screen punya 2 tab: **Produk** dan **Profil**.
4. Tab Produk menampilkan list data dari REST API (backend Node.js).
5. Tekan ikon titik tiga (context menu) di tiap item → **Edit** atau **Hapus**.
6. Tekan tombol **+** untuk menambah produk baru.
7. Tab Profil menampilkan info user yang login + tombol **Logout**.

## Catatan Pengumpulan

Sesuai instruksi soal, satukan folder `backend` dan `mobile_app` ini ke dalam
satu folder dengan format nama:

```
UAS_MobileProgramming_Nama_Kelas_NIM
```
