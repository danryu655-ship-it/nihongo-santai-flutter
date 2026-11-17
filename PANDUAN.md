# Panduan Aplikasi Nihongo Santai

Panduan cara memakai aplikasi dan cara mengubah kodenya sendiri.
Versi aplikasi: **v1.0.0+24** — repo: https://github.com/danryu655-ship-it/nihongo-santai-flutter

---

## 1. Tentang aplikasi

Aplikasi belajar bahasa Jepang (N5–N1) untuk Android, dibuat dengan Flutter.
Sebagian besar fitur jalan **offline** — tidak perlu internet, kecuali terjemah
online dan tombol "Perbarui" kurs tidak ada di aplikasi ini.

Navbar bawah ada **4 tab**: Terjemah, Belajar, Frasa, Kana.
Tab Sekolah sudah **dihapus** di v1.0.0+24 (tidak bisa tersambung dari HP).

Data belajar aplikasi ini **mulai dari nol** — progres dari aplikasi WebView lama
tidak pindah ke sini.

## 2. Cara instal APK

1. Unduh file APK (arm64) dari link yang dibagikan.
2. Buka file APK di HP → izinkan "Instal aplikasi tidak dikenal" bila diminta.
3. Instal menimpa versi lama saja — data belajar (progres, XP, favorit) aman,
   tidak hilang.
4. Splash muncul 30 detik saat aplikasi dibuka — ketuk "Ketuk untuk lanjut"
   untuk melewatinya.

## 3. Cara pakai

### Terjemah

- Ketik kata/kalimat Jepang, Indonesia, atau Inggris, lalu terjemahkan.
- Chip di atas menunjukkan status: Online atau Offline. Ketuk chip untuk
  cek ulang koneksi.
- Kalau online, terjemah memakai layanan Google; kalau offline, memakai
  kamus bawaan aplikasi (489 kata).
- "Paksa offline" membuat aplikasi selalu memakai kamus bawaan, walau HP online.

### Belajar (hub)

Hub Belajar berisi 3 kartu:

- **Belajar** — 48 pelajaran (N5: 19, N4: 10, N3: 8, N2: 6, N1: 5).
  Buka pelajaran, baca materi, jawab latihan. Progres dan XP tersimpan.
- **Konbini** — 33 situasi belanja di konbini (minimarket Jepang).
- **Kuis Travel N5** — 10 soal kuis pilihan ganda bertema perjalanan.

### Frasa

- **Frasa** — 67 frasa sehari-hari. Ketuk tombol suara (🔊) untuk mendengar
  pelafalannya (bahasa Jepang, kecepatan 0.7).
- **Menu** — 41 menu makanan/minuman Jepang, lengkap dengan kartu alergi.

### Kana

- Tab bergambar "あ". Ada dua tab di dalamnya: HIRAGANA dan KATAKANA.
- Tiap huruf ada 71 karakter (Dasar 46 + Dakuten 25), tampil sebagai grid
  5 kolom: huruf + romaji + bar progres.
- Ketuk huruf → berbunyi (TTS Jepang) dan huruf itu menyala.
- Tombol **"PELAJARI KARAKTERNYA"** → kuis 10 soal dua arah (huruf→romaji
  dan romaji→huruf). Jawaban benar +0,25 progres dan +2 XP; salah −0,1.
- Tulisan "X dari 71" di atas grid menunjukkan sudah berapa huruf dipelajari.

## 4. Data tersimpan di HP

Semua data tersimpan **offline di HP** (SharedPreferences, kunci berawalan
`nsf_`), antara lain:

- `nsf_kana_progress` — progres belajar kana per huruf.
- Progres pelajaran, XP, favorit, dan riwayat terjemah.

Menghapus data aplikasi atau meng-uninstal akan menghapus semua progres ini.

## 5. Cara build sendiri di PC

Prasyarat: instal **Flutter** (versi 3.50.0) dan **Android SDK** di PC.

```bash
git clone https://github.com/danryu655-ship-it/nihongo-santai-flutter.git
cd nihongo-santai-flutter
flutter build apk --release --split-per-abi
```

Hasilnya ada di `build/app/outputs/flutter-apk/` — ada 3 file APK
(arm64-v8a, armeabi-v7a, x86_64). Yang dipakai di kebanyakan HP Android
adalah **arm64-v8a**.

Setiap kali mengubah kode, naikkan angka versi di `pubspec.yaml`
(baris `version: 1.0.0+24`) sebelum build — misal jadi `1.0.0+25`.

## 6. Cara edit data dan menambah fitur

### Mengubah isi belajar

Semua data ada di folder `lib/data/`:

| File | Isi |
| --- | --- |
| `dictionary.dart` | Kamus 489 kata |
| `phrases.dart` | 67 frasa |
| `kana.dart` | Huruf hiragana/katakana |
| `lessons.dart` | 48 pelajaran |
| `konbini.dart` | 33 situasi konbini |
| `menu.dart` | 41 menu |
| `quiz.dart` | 10 soal kuis |
| `grammar.dart` | 240 materi tata bahasa |

Ubah file-file itu, lalu build ulang (bagian 5).

### Menambah kartu baru di hub Belajar

Contoh pola yang sudah ada ada di `lib/screens/learn_screen.dart`:

- Kartu "Belajar" di sekitar baris 73, kartu "Konbini" di sekitar baris 96,
  kartu "Kuis Travel N5" di sekitar baris 121.
- Isi tiap kartu ada di bagian bawah file yang sama (misal Konbini di
  sekitar baris 322, Kuis Travel N5 di sekitar baris 370).

Untuk kartu kuis baru, salin pola "Kuis Travel N5" (baris 370 ke bawah):
buat layar kuis baru di `lib/screens/`, ambil soal dari data yang sudah ada
di `lib/data/quiz.dart` atau `lib/data/dictionary.dart`, lalu tambahkan
kartu baru di hub dengan pola yang sama.

### Menambah/mengganti tab navbar

Tab diatur di `lib/main.dart`: Terjemah (baris 125), Belajar (baris 129),
Frasa (baris 133), Kana (baris 144). Daftar layar ada di sekitar baris 105.
Teks subtitle "Translate, Belajar & Kana" ada di baris 191 dan 262.

### Suara (TTS)

Suara Jepang diatur di `lib/services/tts_service.dart` — bahasa `ja-JP`,
kecepatan 0.7. Semua suara di aplikasi (frasa, kamus, menu, kuis, kana)
memakai pengaturan ini.

## 7. Catatan penting

- **Tab Sekolah dihapus (v1.0.0+24).** HP tidak bisa tersambung ke server
  Sekolah (Supabase) — DNS, Wi-Fi, data seluler, VPN, dan relay sudah
  dicoba semua dan tetap gagal. Servernya sendiri baik-baik saja.
  Sinkronisasi progres tetap berjalan diam-diam di latar belakang.
- **Kuis Kotoba dan tombol chat tengah belum ada.** Penambahannya tertunda
  karena build dari Rias ditolak sistem (7x, 15–16 Nov 2026). Kalau mau
  menambahkannya sendiri, ikuti pola di bagian 6.
- **Ikon aplikasi** dibuat dari gambar `dp-nihongosantai.jpg` dan logo di
  dalam aplikasi sudah ada di header.

---

*Panduan ini dibuat 17 Nov 2026 untuk v1.0.0+24. Kalau versi aplikasi
berubah, nomor baris di bagian 6 bisa bergeser — cari nama file dan
judul kartu/bagiannya.*
