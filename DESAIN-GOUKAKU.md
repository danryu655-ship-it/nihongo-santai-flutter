# Rincian Desain — Tampilan ala Nihongo Goukaku

Rincian tertulis tampilan aplikasi referensi (screenshot 22 Nov 2026) untuk
diterapkan sendiri ke aplikasi Nihongo Santai di PC.
**Ini rincian desain saja, bukan kode.** Cara build dan letak file ada di
`PANDUAN.md`.

Referensi: aplikasi "Nihongo Goukaku" (@muramd) — belajar JLPT N3–N2.

---

## 1. Gaya visual keseluruhan

- **Latar:** abu-biru muda yang lembut (kira-kira `#E9EDF2`).
- **Kartu gelap:** biru-slate (kira-kira `#5A6B7D`), teks putih/krem.
- **Kartu terang:** krem pucat (kira-kira `#F7F1DE`) dan putih.
- **Aksen:** merah untuk furigana/teks Jepang kecil; biru-slate untuk tombol.
- **Bentuk:** sudut sangat membulat (radius besar, kira-kira 24px) di semua
  kartu, tombol, dan panel.
- **Huruf:** sans-serif membulat, judul tebal, isi regular.
- **Ilustrasi:** gambar kartun kecil (dua siswa belajar, maskot kucing,
  daruma, pensil, stopwatch) di pojok header/kartu — bukan foto.
- **Bayangan:** lembut dan tipis di bawah kartu putih.

## 2. Beranda

- Header: logo teks "Nihongo Goukaku" di tengah, ikon profil bulat kiri,
  ikon lonceng kanan.
- Sapaan: "Halo, MURAMD" + "Progress: 0%" + avatar bulat.
- Baris status: chip poin (💎 435), chip level ("N2 | Beginner"),
  kolom cari ("Kamus cepat").
- Kartu besar "Lanjutkan belajar" (gelap): label "FLASHCARD · N3",
  "Kanji: 0 dari 387 kartu dikuasai", tombol panah bundar, ilustrasi
  kartu flashcard + daruma + pensil + stopwatch.
- Chip cepat: Kosakata (語), Kanji (漢), Bunpou (文).
- Kartu 2 kolom:
  - "APA YANG BARU — Fitur baru: Teman & Duet" (terang).
  - "KARTU PROFIL — Profilku: Kartu profil, rank, dan gelar" (gelap).
  - "Papan Peringkat — Top: Lihat posisimu" (terang).
  - "MY TANGO — 4 kata menunggu" (terang, dengan chip level).
- Navbar bawah 5 ikon: Beranda, Belajar, Teman, Toko, Profil.
  Maskot kucing kecil mengambang di kanan bawah.

## 3. Hub Belajar

- Header besar: judul "Belajar" + deskripsi "Flashcard, materi, latihan
  soal, dan ujian JLPT." + ilustrasi dua siswa di meja belajar (kanan).
- Grid 2x2 kartu besar (masing-masing ada ikon bundar + panah bundar):
  - **Flashcard** (暗記, terang): "Kosakata, Kanji, Bunpou".
  - **Materi** (教材, terang): "Daftar kartu, tambah, import".
  - **Kursus** (目標, GELAP): "Susun rencana belajarmu".
  - **MyGoukaku** (PROGRES, krem): "Skor, riwayat, kesiapan JLPT".
- Judul bagian: "Latihan Soal".
- Kartu latihan memanjang (putih, ikon kiri + panah kanan):
  - **Moji-Goi** (文字・語彙): "10 soal: kanji, kosakata, pemakaian kata".
  - **Bunpou** (文法): "10 soal: tata bahasa dan susunan kalimat".

## 4. Layar Materi

- Header: tombol kembali (kiri), judul "Materi", tombol filter (kanan),
  ilustrasi siswa (kanan atas).
- Pemilih level: dropdown "N3".
- Tab: Kosakata | Kanji | Bunpou (tab aktif = latar gelap, teks putih).
- Pemilih BAB: lingkaran bernomor 1–7 (aktif = gelap).
- Kartu BAB (gelap): "BAB 1", "28 kartu", bar progres, "0 hafal",
  tombol "Mulai Flashcard" (putih) dan "Mulai Latihan" (outline putih).
- **Kartu Kosakata** (putih, 2 kolom): furigana merah di atas,
  kanji besar di tengah, arti Indonesia di bawah; ikon kecil di atas
  (あ, 💡, ＋). Contoh: 長女 ちょうじょ — ANAK PEREMPUAN PERTAMA.
- **Kartu Kanji** (putih, 2 kolom): label ON (gelap) + bacaan, label KUN
  + bacaan, kanji besar, 4 chip kecil di bawah (部, 例, 似, 書).
  Contoh: 信 — ON シン, KUN —.
- **Kartu Bunpou** (putih, 1 kolom): pola besar (misal 〜たばかり),
  label "ARTI", arti Indonesia, ikon 💡 di kanan.
  Contoh: 〜たばかり — "Baru saja selesai (perasaan subjektif)".

## 5. Detail Kanji (panel bawah / bottom sheet)

Ketuk kartu kanji → panel bawah membulat muncul:

- Kanji besar di tengah (信), ON'YOMI シン | KUN'YOMI —.
- 3 chip: 書き方 (cara tulis) | 例 Kosakata | 似 Mirip.
- Chip arti: "Kepercayaan", "yakin".
- **BUSYU (radikal pembentuk):** dua kotak — 亻 にんべん (orang) +
  言 げん (kata, bicara) — dengan kalimat ilustrasi:
  "Orang (亻) yang kata-katanya (言) bisa dipegang adalah orang yang
  dapat dipercaya."
- Status: "Belum hafal", "BAB 1".
- Tombol bawah: "Edit" (kiri) dan "Hapus" (kanan, teks merah).
- Sub-panel yang dibuka dari chip:
  - **Busu (亻):** "KANJI DENGAN 亻 BIASANYA TENTANG — manusia: sifat,
    peran, tindakan"; "CARA MENGINGAT — Orang berdiri dari samping";
    "JANGAN TERTUKAR DENGAN — 彳 (jalan, mis. 行く, 待つ), punya satu
    goresan miring lagi"; "KANJI LAIN DI DECK-MU DENGAN 亻 — 件 側 任".
  - **Kosakata (例):** daftar kata dengan kanji itu — 信じる percaya,
    信仰 kepercayaan/keimanan, 信号 lampu lalu lintas,
    信用 kepercayaan, 信頼 rasa percaya, 通信 komunikasi.
  - **Mirip (似):** kanji mirip 言 (kata, berkata) — ON ゲン, KUN こと;
    "BEDANYA: 信 punya 亻 di kiri; 言 tidak"; contoh 言語 bahasa,
    言葉 kata.

## 6. Pemetaan ke aplikasi Nihongo Santai

Yang perlu diubah (lihat `PANDUAN.md` untuk letak file):

| Bagian referensi | Padanan di aplikasi kita |
| --- | --- |
| Hub Belajar 2x2 (Flashcard, Materi, Kursus, MyGoukaku) | Hub Belajar di `lib/screens/learn_screen.dart` (kartu Belajar, Konbini, Kuis Travel N5) |
| Tab Kosakata / Kanji / Bunpou + BAB 1–7 | Layar materi baru — data bab dari `lib/data/lessons.dart` |
| Kartu Kosakata (furigana + kanji + arti) | Data di `lib/data/dictionary.dart` (489 kata) |
| Kartu Kanji (ON/KUN + chip) | Data kanji — belum ada; perlu data baru (kanji, ON, KUN, radikal) |
| Kartu Bunpou (pola + arti) | Data di `lib/data/grammar.dart` (240 materi) |
| Detail Kanji (bottom sheet + busu + mirip + kosakata) | Panel baru — butuh data radikal, mnemonik, kanji mirip, contoh kosakata |
| Gaya visual (latar abu-biru, kartu gelap/krem, radius besar) | Warna & tema di `lib/main.dart` dan tiap screen |

Catatan penting:

- Aplikasi kita sekarang level N5–N1 dan data kanji terpisah (Kana hanya
  hiragana/katakana). Detail kanji ala Goukaku butuh **data baru**
  (radikal/busu, mnemonik, kanji mirip) yang tidak ada di aplikasi kita.
- Warna aplikasi kita sekarang indigo (`#4338ca`); referensi memakai
  biru-slate + krem. Ganti warna berarti mengubah tema di banyak tempat.
- Mulai dari yang paling mudah: ubah dulu warna latar + bentuk kartu
  (radius besar) di hub Belajar, baru tambah tab Materi dan detail kanji.

---

*Rincian dibuat 22 Nov 2026 dari 10 screenshot referensi.
Nomor baris file bisa bergeser kalau versi aplikasi berubah.*
