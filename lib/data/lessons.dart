// Data diekstrak otomatis dari app/index.html (LESSONS baris 1427, LEVELS baris 1479).
// Jangan edit manual — jalankan ulang tools/extract-data.mjs bila sumber berubah.

import 'kana.dart';

/// Satu pelajaran belajar (N5–N1).
class Lesson {
  const Lesson({
    required this.level,
    required this.id,
    required this.track,
    required this.icon,
    required this.title,
    required this.description,
    required this.kind,
    this.script,
    this.kanaSet,
    this.categories,
    this.grammarId,
    this.intro,
  });

  /// Level: N5 | N4 | N3 | N2 | N1 (field `lvl`).
  final String level;

  /// ID pelajaran (field `id`).
  final String id;

  /// Jalur/track pelajaran (field `track`).
  final String track;

  /// Ikon (huruf kana atau emoji, field `icon`).
  final String icon;

  /// Judul (field `title`).
  final String title;

  /// Deskripsi (field `desc`).
  final String description;

  /// Jenis: 'kana' | 'vocab' | 'grammar' (field `kind`).
  final String kind;

  /// Skrip kana: 'h' = hiragana, 'k' = katakana (field `script`, hanya kind kana).
  final String? script;

  /// Huruf kana pelajaran ini (field `set`, hanya kind kana).
  /// Di sumber berupa potongan HIRA/KATA — sudah di-resolve jadi huruf nyata.
  final List<KanaChar>? kanaSet;

  /// Kunci kategori kamus (field `cats`, hanya kind vocab).
  final List<String>? categories;

  /// ID grup soal tata bahasa (field `gid`, hanya kind grammar).
  final String? grammarId;

  /// Pengantar materi (field `intro`, hanya kind grammar).
  /// Tag HTML tebal (b) dari sumber sudah dihilangkan, isi dipertahankan.
  final String? intro;
}

/// Satu level belajar.
class LevelInfo {
  const LevelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  /// ID level (field `id`).
  final String id;

  /// Nama tampil (field `name`).
  final String name;

  /// Deskripsi (field `desc`).
  final String description;

  /// Ikon (field `icon`).
  final String icon;
}

/// Daftar level (5 level).
const List<LevelInfo> levels = [
  LevelInfo(id: "N5", name: "N5", description: "Pemula", icon: "🌱"),
  LevelInfo(id: "N4", name: "N4", description: "Dasar", icon: "🌿"),
  LevelInfo(id: "N3", name: "N3", description: "Menengah", icon: "🌳"),
  LevelInfo(id: "N2", name: "N2", description: "Lanjut", icon: "🏔️"),
  LevelInfo(id: "N1", name: "N1", description: "Mahir", icon: "👑"),
];

/// Daftar pelajaran (48 pelajaran).
const List<Lesson> lessons = [
  Lesson(level: "N5", id: "h1", track: "Hiragana", icon: "あ", title: "Hiragana 1 — あ行・か行", description: "Huruf a i u e o dan ka ki ku ke ko", kind: "kana", script: "h", kanaSet: [
    KanaChar("あ", "a"),
    KanaChar("い", "i"),
    KanaChar("う", "u"),
    KanaChar("え", "e"),
    KanaChar("お", "o"),
    KanaChar("か", "ka"),
    KanaChar("き", "ki"),
    KanaChar("く", "ku"),
    KanaChar("け", "ke"),
    KanaChar("こ", "ko"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "h2", track: "Hiragana", icon: "さ", title: "Hiragana 2 — さ行・た行", description: "Huruf sa shi su se so dan ta chi tsu te to", kind: "kana", script: "h", kanaSet: [
    KanaChar("さ", "sa"),
    KanaChar("し", "shi"),
    KanaChar("す", "su"),
    KanaChar("せ", "se"),
    KanaChar("そ", "so"),
    KanaChar("た", "ta"),
    KanaChar("ち", "chi"),
    KanaChar("つ", "tsu"),
    KanaChar("て", "te"),
    KanaChar("と", "to"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "h3", track: "Hiragana", icon: "な", title: "Hiragana 3 — な行・は行", description: "Huruf na ni nu ne no dan ha hi fu he ho", kind: "kana", script: "h", kanaSet: [
    KanaChar("な", "na"),
    KanaChar("に", "ni"),
    KanaChar("ぬ", "nu"),
    KanaChar("ね", "ne"),
    KanaChar("の", "no"),
    KanaChar("は", "ha"),
    KanaChar("ひ", "hi"),
    KanaChar("ふ", "fu"),
    KanaChar("へ", "he"),
    KanaChar("ほ", "ho"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "h4", track: "Hiragana", icon: "ま", title: "Hiragana 4 — ま行・や行・ら行・わ行", description: "Huruf ma mi mu me mo, ya yu yo, ra ri ru re ro, wa wo, n", kind: "kana", script: "h", kanaSet: [
    KanaChar("ま", "ma"),
    KanaChar("み", "mi"),
    KanaChar("む", "mu"),
    KanaChar("め", "me"),
    KanaChar("も", "mo"),
    KanaChar("や", "ya"),
    KanaChar("ゆ", "yu"),
    KanaChar("よ", "yo"),
    KanaChar("ら", "ra"),
    KanaChar("り", "ri"),
    KanaChar("る", "ru"),
    KanaChar("れ", "re"),
    KanaChar("ろ", "ro"),
    KanaChar("わ", "wa"),
    KanaChar("を", "wo"),
    KanaChar("ん", "n"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "h5", track: "Hiragana", icon: "が", title: "Hiragana 5 — Dakuten & ulasan", description: "がざだばぱ dan ulasan semua hiragana", kind: "kana", script: "h", kanaSet: [
    KanaChar("が", "ga"),
    KanaChar("ぎ", "gi"),
    KanaChar("ぐ", "gu"),
    KanaChar("げ", "ge"),
    KanaChar("ご", "go"),
    KanaChar("ざ", "za"),
    KanaChar("じ", "ji"),
    KanaChar("ず", "zu"),
    KanaChar("ぜ", "ze"),
    KanaChar("ぞ", "zo"),
    KanaChar("だ", "da"),
    KanaChar("ぢ", "ji"),
    KanaChar("づ", "zu"),
    KanaChar("で", "de"),
    KanaChar("ど", "do"),
    KanaChar("ば", "ba"),
    KanaChar("び", "bi"),
    KanaChar("ぶ", "bu"),
    KanaChar("べ", "be"),
    KanaChar("ぼ", "bo"),
    KanaChar("ぱ", "pa"),
    KanaChar("ぴ", "pi"),
    KanaChar("ぷ", "pu"),
    KanaChar("ぺ", "pe"),
    KanaChar("ぽ", "po"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "k1", track: "Katakana", icon: "ア", title: "Katakana 1 — ア行・カ行", description: "Huruf a i u e o dan ka ki ku ke ko", kind: "kana", script: "k", kanaSet: [
    KanaChar("ア", "a"),
    KanaChar("イ", "i"),
    KanaChar("ウ", "u"),
    KanaChar("エ", "e"),
    KanaChar("オ", "o"),
    KanaChar("カ", "ka"),
    KanaChar("キ", "ki"),
    KanaChar("ク", "ku"),
    KanaChar("ケ", "ke"),
    KanaChar("コ", "ko"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "k2", track: "Katakana", icon: "サ", title: "Katakana 2 — サ行・タ行", description: "Huruf sa shi su se so dan ta chi tsu te to", kind: "kana", script: "k", kanaSet: [
    KanaChar("サ", "sa"),
    KanaChar("シ", "shi"),
    KanaChar("ス", "su"),
    KanaChar("セ", "se"),
    KanaChar("ソ", "so"),
    KanaChar("タ", "ta"),
    KanaChar("チ", "chi"),
    KanaChar("ツ", "tsu"),
    KanaChar("テ", "te"),
    KanaChar("ト", "to"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "k3", track: "Katakana", icon: "ナ", title: "Katakana 3 — ナ行・ハ行", description: "Huruf na ni nu ne no dan ha hi fu he ho", kind: "kana", script: "k", kanaSet: [
    KanaChar("ナ", "na"),
    KanaChar("ニ", "ni"),
    KanaChar("ヌ", "nu"),
    KanaChar("ネ", "ne"),
    KanaChar("ノ", "no"),
    KanaChar("ハ", "ha"),
    KanaChar("ヒ", "hi"),
    KanaChar("フ", "fu"),
    KanaChar("ヘ", "he"),
    KanaChar("ホ", "ho"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "k4", track: "Katakana", icon: "マ", title: "Katakana 4 — マ行・ヤ行・ラ行・ワ行", description: "Huruf ma mi mu me mo, ya yu yo, ra ri ru re ro, wa wo, n", kind: "kana", script: "k", kanaSet: [
    KanaChar("マ", "ma"),
    KanaChar("ミ", "mi"),
    KanaChar("ム", "mu"),
    KanaChar("メ", "me"),
    KanaChar("モ", "mo"),
    KanaChar("ヤ", "ya"),
    KanaChar("ユ", "yu"),
    KanaChar("ヨ", "yo"),
    KanaChar("ラ", "ra"),
    KanaChar("リ", "ri"),
    KanaChar("ル", "ru"),
    KanaChar("レ", "re"),
    KanaChar("ロ", "ro"),
    KanaChar("ワ", "wa"),
    KanaChar("ヲ", "wo"),
    KanaChar("ン", "n"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "k5", track: "Katakana", icon: "ガ", title: "Katakana 5 — Dakuten & ulasan", description: "ガザダバパ dan ulasan semua katakana", kind: "kana", script: "k", kanaSet: [
    KanaChar("ガ", "ga"),
    KanaChar("ギ", "gi"),
    KanaChar("グ", "gu"),
    KanaChar("ゲ", "ge"),
    KanaChar("ゴ", "go"),
    KanaChar("ザ", "za"),
    KanaChar("ジ", "ji"),
    KanaChar("ズ", "zu"),
    KanaChar("ゼ", "ze"),
    KanaChar("ゾ", "zo"),
    KanaChar("ダ", "da"),
    KanaChar("ヂ", "ji"),
    KanaChar("ヅ", "zu"),
    KanaChar("デ", "de"),
    KanaChar("ド", "do"),
    KanaChar("バ", "ba"),
    KanaChar("ビ", "bi"),
    KanaChar("ブ", "bu"),
    KanaChar("ベ", "be"),
    KanaChar("ボ", "bo"),
    KanaChar("パ", "pa"),
    KanaChar("ピ", "pi"),
    KanaChar("プ", "pu"),
    KanaChar("ペ", "pe"),
    KanaChar("ポ", "po"),
  ], categories: null, grammarId: null, intro: null),
  Lesson(level: "N5", id: "v1", track: "Kosakata N5", icon: "👋", title: "Kosakata 1 — Sapaan & angka", description: "20 kata: sapaan dasar dan angka 1–10000", kind: "vocab", script: null, kanaSet: null, categories: ["sapaan", "angka"], grammarId: null, intro: null),
  Lesson(level: "N5", id: "v2", track: "Kosakata N5", icon: "🕐", title: "Kosakata 2 — Waktu & keluarga", description: "Waktu, hari, dan anggota keluarga", kind: "vocab", script: null, kanaSet: null, categories: ["waktu", "keluarga"], grammarId: null, intro: null),
  Lesson(level: "N5", id: "v3", track: "Kosakata N5", icon: "🍜", title: "Kosakata 3 — Makanan & perjalanan", description: "Makanan, minuman, bandara, dan arah", kind: "vocab", script: null, kanaSet: null, categories: ["makanan", "perjalanan"], grammarId: null, intro: null),
  Lesson(level: "N5", id: "v4", track: "Kosakata N5", icon: "🏨", title: "Kosakata 4 — Hotel, restoran & tempat", description: "Hotel, restoran, tempat, dan alam", kind: "vocab", script: null, kanaSet: null, categories: ["hotel", "restoran", "tempat"], grammarId: null, intro: null),
  Lesson(level: "N5", id: "v5", track: "Kosakata N5", icon: "🏃", title: "Kosakata 5 — Kata kerja, sifat & benda", description: "Kata kerja N5, kata sifat, dan benda sehari-hari", kind: "vocab", script: null, kanaSet: null, categories: ["kerja", "sifat", "benda"], grammarId: null, intro: null),
  Lesson(level: "N5", id: "g1", track: "Tata bahasa", icon: "📝", title: "Tata bahasa 1 — です / ます", description: "Kalimat sopan: kata benda + です, kata kerja + ます", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g1", intro: "Dalam bahasa Jepang sopan, kalimat diakhiri です (untuk kata benda / kata sifat) atau ます (untuk kata kerja). Contoh: わたしはダニエルです (Saya adalah Daniel), 本を読みます (Saya membaca buku)."),
  Lesson(level: "N5", id: "g2", track: "Tata bahasa", icon: "📝", title: "Tata bahasa 2 — Partikel は / が", description: "は menandai topik, が menandai subjek", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g2", intro: "は (dibaca “wa”) menandai topik — hal yang sedang dibicarakan. が menandai subjek, sering untuk hal baru atau penekanan. Contoh: わたしは学生です (topik: saya) — だれが来ましたか (subjek: siapa)."),
  Lesson(level: "N5", id: "g3", track: "Tata bahasa", icon: "📝", title: "Tata bahasa 3 — Partikel を / に / で", description: "を = objek, に = tujuan, で = tempat kegiatan", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g3", intro: "を (dibaca “o”) menandai objek: 本を読みます. に menandai tujuan: 学校に行きます. で menandai tempat kegiatan: 家で勉強します."),
  Lesson(level: "N5", id: "g4", track: "Tata bahasa", icon: "📝", title: "Tata bahasa 4 — Kata sifat-i & golongan kerja", description: "Kata sifat berakhiran い, dan 3 golongan kata kerja", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g4", intro: "Kata sifat-i berakhiran い: 大きい, 暑い. Negatifnya: い → くないです (暑くないです). Kata kerja ada 3 golongan: golongan 1 (書く→書きます), golongan 2 (食べる→食べます), golongan 3 (する→します, 来る→来ます)."),
  Lesson(level: "N4", id: "n4v1", track: "Kosakata N4", icon: "🏃", title: "Kosakata N4 — 1: Kata kerja", description: "Kata kerja N4: meminjam, mengirim, memulai, mencari, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n4"], grammarId: null, intro: null),
  Lesson(level: "N4", id: "n4v2", track: "Kosakata N4", icon: "✨", title: "Kosakata N4 — 2: Kata sifat", description: "Kata sifat N4: terang, berat, kuat, manis, pedas, aman, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n4"], grammarId: null, intro: null),
  Lesson(level: "N4", id: "n4v3", track: "Kosakata N4", icon: "📍", title: "Kosakata N4 — 3: Tempat & perjalanan", description: "Tempat dan perjalanan N4: kereta bawah tanah, taman, musim, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n4"], grammarId: null, intro: null),
  Lesson(level: "N4", id: "n4v4", track: "Kosakata N4", icon: "📘", title: "Kosakata N4 — 4: Campuran", description: "Latihan acak dari 100 kata N4: sekolah, ujian, bahasa Jepang, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n4"], grammarId: null, intro: null),
  Lesson(level: "N4", id: "n4g1", track: "Tata bahasa N4", icon: "📝", title: "Tata bahasa N4 — 1: Bentuk te", description: "Bentuk te: 書いて, 読んで, 食べて, して, 来て", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g5", intro: "Bentuk te dipakai untuk permintaan (〜てください), menghubungkan kalimat, dan bentuk sedang (〜ている). Cara membentuk: golongan 1: く→いて, ぐ→いで, す→して, う・つ・る→って, ぬ・ぶ・む→んで; golongan 2: hapus る + て; golongan 3: する→して, 来る→来て (きて)。"),
  Lesson(level: "N4", id: "n4g2", track: "Tata bahasa N4", icon: "📝", title: "Tata bahasa N4 — 2: Bentuk ta & nai", description: "Bentuk lampau (ta) dan negatif biasa (nai)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g6", intro: "Bentuk ta = lampau (te → ta: いて→いた, んで→んだ, って→った, して→した). Bentuk nai = negatif biasa (golongan 1: akhiran -u → -a + ない; golongan 2: hapus る + ない; する→しない, 来る→来ない)。"),
  Lesson(level: "N4", id: "n4g3", track: "Tata bahasa N4", icon: "📝", title: "Tata bahasa N4 — 3: ~tai (ingin)", description: "〜たい = ingin: 食べたい, 行きたい, 飲みたい", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g7", intro: "Pola 〜たい = ingin. Caranya: bentuk ます tanpa ます + たい (食べます → 食べたい). Negatifnya: たい → たくない (食べたくない). Bentuk sopannya: たいです。"),
  Lesson(level: "N4", id: "n4g4", track: "Tata bahasa N4", icon: "📝", title: "Tata bahasa N4 — 4: ~nakereba narimasen (harus)", description: "〜なければなりません = harus: 行かなければなりません", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g8", intro: "Pola 〜なければなりません = harus. Caranya: bentuk nai tanpa い + ければなりません (行かない → 行かなければなりません). する → しなければなりません, 来る → 来なければなりません (こなければなりません)。"),
  Lesson(level: "N4", id: "n4g5", track: "Tata bahasa N4", icon: "📝", title: "Tata bahasa N4 — 5: ~temo ii / ~tewa ikenai", description: "〜てもいい = boleh, 〜てはいけない = tidak boleh", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g9", intro: "〜てもいい = boleh (te + もいい). 〜てはいけない = tidak boleh (te + はいけない). Contoh: 食べてもいいです (boleh makan), 食べてはいけません (tidak boleh makan)。"),
  Lesson(level: "N4", id: "n4g6", track: "Tata bahasa N4", icon: "📝", title: "Tata bahasa N4 — 6: ~tara & ~toki", description: "〜たら = kalau/jika, 〜とき = saat/ketika", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g10", intro: "〜たら = kalau / jika (bentuk ta + ら: 降ったら). 〜とき = saat / ketika (bentuk biasa + とき: 食べるとき; bentuk ta + とき untuk lampau: 行ったとき)。"),
  Lesson(level: "N3", id: "n3v1", track: "Kosakata N3", icon: "📗", title: "Kosakata N3 — 1: Kata kerja & benda", description: "Kata kerja dan benda N3: usaha, pengalaman, rapat, hewan, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n3"], grammarId: null, intro: null),
  Lesson(level: "N3", id: "n3v2", track: "Kosakata N3", icon: "📗", title: "Kosakata N3 — 2: Campuran", description: "Latihan acak dari 80 kata N3: kesehatan, perjalanan, cuaca, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n3"], grammarId: null, intro: null),
  Lesson(level: "N3", id: "n3g1", track: "Tata bahasa N3", icon: "📝", title: "Tata bahasa N3 — 1: ~te shimau", description: "〜てしまう = sudah terlanjur / selesai total", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g11", intro: "〜てしまう = sudah selesai total / terlanjur (kadang dengan rasa menyesal). Contoh: 忘れてしまった (terlanjur lupa), 食べてしまった (sudah habis dimakan)。"),
  Lesson(level: "N3", id: "n3g2", track: "Tata bahasa N3", icon: "📝", title: "Tata bahasa N3 — 2: ~te miru", description: "〜てみる = mencoba: 食べてみる, 行ってみる", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g12", intro: "〜てみる = mencoba. Contoh: 食べてみる (mencoba makan), 行ってみる (mencoba pergi)。"),
  Lesson(level: "N3", id: "n3g3", track: "Tata bahasa N3", icon: "📝", title: "Tata bahasa N3 — 3: ~sou da (katanya)", description: "〜そうだ = katanya (dari kabar orang)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g13", intro: "〜そうだ (dari kabar) = katanya. Bentuk biasa + そうだ: 降るそうです (katanya akan hujan). Jangan tertukar dengan “kelihatannya”: おいしそうです (kelihatannya enak) — “い”-nya hilang。"),
  Lesson(level: "N3", id: "n3g4", track: "Tata bahasa N3", icon: "📝", title: "Tata bahasa N3 — 4: ~you da (sepertinya)", description: "〜ようだ = sepertinya (dari pengamatan sendiri)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g14", intro: "〜ようだ = sepertinya (dari pengamatan sendiri). Kata kerja biasa + ようだ, kata benda + の + ようだ, kata sifat-na + な + ようだ。"),
  Lesson(level: "N3", id: "n3g5", track: "Tata bahasa N3", icon: "📝", title: "Tata bahasa N3 — 5: ~rashii (khas)", description: "〜らしい = khas / seperti layaknya", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g15", intro: "〜らしい = khas / seperti layaknya. Contoh: 学生らしい (khas mahasiswa), 春らしい (khas musim semi)。"),
  Lesson(level: "N3", id: "n3g6", track: "Tata bahasa N3", icon: "📝", title: "Tata bahasa N3 — 6: ~bakari (baru saja)", description: "〜たばかり = baru saja: 食べたばかり", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g16", intro: "〜たばかり = baru saja. Bentuk ta + ばかり: 食べたばかり (baru saja makan), 来たばかり (baru saja datang)。"),
  Lesson(level: "N2", id: "n2v1", track: "Kosakata N2", icon: "📙", title: "Kosakata N2 — Campuran", description: "Latihan dari 60 kata N2: penilaian, keputusan, kerja sama, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n2"], grammarId: null, intro: null),
  Lesson(level: "N2", id: "n2g1", track: "Tata bahasa N2", icon: "📝", title: "Tata bahasa N2 — 1: ~wake da", description: "〜わけだ = pantas saja / jadi (penjelasan)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g17", intro: "〜わけだ = pantas saja / jadi (penjelasan dari alasan). Contoh: 毎日練習しているから、上手なわけだ. Lawannya: 〜わけがない = tidak mungkin。"),
  Lesson(level: "N2", id: "n2g2", track: "Tata bahasa N2", icon: "📝", title: "Tata bahasa N2 — 2: ~hazu da", description: "〜はずだ = seharusnya / pasti (harapan)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g18", intro: "〜はずだ = seharusnya / pasti (harapan atau perkiraan). Contoh: 来るはずだ (seharusnya datang). Lawannya: 〜はずがない = tidak mungkin。"),
  Lesson(level: "N2", id: "n2g3", track: "Tata bahasa N2", icon: "📝", title: "Tata bahasa N2 — 3: ~ni chigainai", description: "〜にちがいない = pasti (keyakinan kuat)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g19", intro: "〜にちがいない = pasti (keyakinan sangat kuat). Contoh: 彼は来るにちがいない (dia pasti datang). Lebih kuat dari 〜はずだ。"),
  Lesson(level: "N2", id: "n2g4", track: "Tata bahasa N2", icon: "📝", title: "Tata bahasa N2 — 4: Keigo dasar", description: "Bahasa hormat: 召し上がる, いただく, 伺う, 申す", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g20", intro: "Keigo = bahasa hormat. Sonkeigo (untuk orang lain): いらっしゃる, 召し上がる, おっしゃる, ご覧になる. Kenjougo (untuk diri sendiri): 申す, 伺う, 拝見する, いただく。"),
  Lesson(level: "N2", id: "n2g5", track: "Tata bahasa N2", icon: "📝", title: "Tata bahasa N2 — 5: ~zaru wo enai", description: "〜ざるを得ない = terpaksa / tidak ada pilihan lain", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g21", intro: "〜ざるを得ない = terpaksa / tidak ada pilihan lain. Caranya: bentuk nai tanpa い + ざるを得ない (行かない → 行かざるを得ない)。"),
  Lesson(level: "N1", id: "n1v1", track: "Kosakata N1", icon: "📕", title: "Kosakata N1 — 1: Kata kerja & sifat", description: "Kata kerja dan sifat N1: ragu, terpaksa, menonjol, hati-hati, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n1"], grammarId: null, intro: null),
  Lesson(level: "N1", id: "n1v2", track: "Kosakata N1", icon: "📕", title: "Kosakata N1 — 2: Campuran", description: "Latihan dari 40 kata N1: keigo, kata kerja gabungan, dan lainnya", kind: "vocab", script: null, kanaSet: null, categories: ["n1"], grammarId: null, intro: null),
  Lesson(level: "N1", id: "n1g1", track: "Tata bahasa N1", icon: "📝", title: "Tata bahasa N1 — 1: ~wo yoginaku sareru", description: "〜を余儀なくされる = terpaksa (karena keadaan)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g22", intro: "〜を余儀なくされる = terpaksa (karena keadaan, tidak diinginkan). Kata benda + を + 余儀なくされる: 中止を余儀なくされた (terpaksa dibatalkan)。"),
  Lesson(level: "N1", id: "n1g2", track: "Tata bahasa N1", icon: "📝", title: "Tata bahasa N1 — 2: ~ni sakidatte", description: "〜に先立って = sebelum (formal, tertulis)", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g23", intro: "〜に先立って = sebelum (formal, tertulis). Kata benda + に先立って: 会議に先立って (sebelum rapat)。"),
  Lesson(level: "N1", id: "n1g3", track: "Tata bahasa N1", icon: "📝", title: "Tata bahasa N1 — 3: ~wo kawakiri ni", description: "〜をかわきりに = mulai dari … sebagai titik awal", kind: "grammar", script: null, kanaSet: null, categories: null, grammarId: "g24", intro: "〜をかわきりに = mulai dari … sebagai titik awal / titik balik. Contoh: 今日をかわきりに (mulai hari ini)。"),
];
