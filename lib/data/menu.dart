// Data diekstrak otomatis dari app/index.html (MENU baris 1083, ALERGI baris 1126, diet dari select #dietSel + showAlergiCard()).
// Jangan edit manual — jalankan ulang tools/extract-data.mjs bila sumber berubah.

/// Satu kata menu restoran (decoder menu).
class MenuItem {
  const MenuItem({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
    required this.category,
  });

  /// Kata Jepang (field `ja`).
  final String japanese;

  /// Romaji (field `rm`).
  final String romaji;

  /// Arti Bahasa Indonesia (field `id`).
  final String indonesian;

  /// Kategori (field `c`).
  final String category;
}

/// Satu alergen untuk kartu alergi.
class AllergyItem {
  const AllergyItem({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
  });

  /// Nama alergen Jepang (field `ja`).
  final String japanese;

  /// Romaji (field `rm`).
  final String romaji;

  /// Arti Bahasa Indonesia (field `id`).
  final String indonesian;
}

/// Satu pilihan diet untuk kartu alergi & diet.
class DietOption {
  const DietOption({
    required this.id,
    required this.japanese,
    required this.indonesian,
  });

  /// Nilai opsi (value pada option HTML: veg / halal / nopork / nospicy).
  final String id;

  /// Kalimat Jepang yang ditampilkan ke staf restoran.
  final String japanese;

  /// Arti Bahasa Indonesia.
  final String indonesian;
}

/// Kata menu (41 kata).
const List<MenuItem> menuItems = [
  MenuItem(japanese: "ラーメン", romaji: "rāmen", indonesian: "Mi ramen", category: "Mi"),
  MenuItem(japanese: "うどん", romaji: "udon", indonesian: "Mi udon", category: "Mi"),
  MenuItem(japanese: "そば", romaji: "soba", indonesian: "Mi soba", category: "Mi"),
  MenuItem(japanese: "焼きそば", romaji: "yakisoba", indonesian: "Mi goreng", category: "Mi"),
  MenuItem(japanese: "つけ麺", romaji: "tsukemen", indonesian: "Mi celup kuah", category: "Mi"),
  MenuItem(japanese: "ご飯", romaji: "gohan", indonesian: "Nasi", category: "Nasi"),
  MenuItem(japanese: "丼", romaji: "donburi", indonesian: "Nasi mangkuk", category: "Nasi"),
  MenuItem(japanese: "牛丼", romaji: "gyūdon", indonesian: "Nasi daging sapi", category: "Nasi"),
  MenuItem(japanese: "親子丼", romaji: "oyakodon", indonesian: "Nasi ayam telur", category: "Nasi"),
  MenuItem(japanese: "カツ丼", romaji: "katsudon", indonesian: "Nasi katsu", category: "Nasi"),
  MenuItem(japanese: "チャーハン", romaji: "chāhan", indonesian: "Nasi goreng", category: "Nasi"),
  MenuItem(japanese: "カレーライス", romaji: "karē raisu", indonesian: "Nasi kari", category: "Nasi"),
  MenuItem(japanese: "おにぎり", romaji: "onigiri", indonesian: "Nasi kepal", category: "Nasi"),
  MenuItem(japanese: "寿司", romaji: "sushi", indonesian: "Sushi", category: "Sushi & Ikan"),
  MenuItem(japanese: "刺身", romaji: "sashimi", indonesian: "Sashimi", category: "Sushi & Ikan"),
  MenuItem(japanese: "まぐろ", romaji: "maguro", indonesian: "Tuna", category: "Sushi & Ikan"),
  MenuItem(japanese: "サーモン", romaji: "sāmon", indonesian: "Salmon", category: "Sushi & Ikan"),
  MenuItem(japanese: "えび", romaji: "ebi", indonesian: "Udang", category: "Sushi & Ikan"),
  MenuItem(japanese: "天ぷら", romaji: "tenpura", indonesian: "Tempura", category: "Daging"),
  MenuItem(japanese: "とんかつ", romaji: "tonkatsu", indonesian: "Daging babi goreng tepung", category: "Daging"),
  MenuItem(japanese: "唐揚げ", romaji: "karaage", indonesian: "Ayam goreng", category: "Daging"),
  MenuItem(japanese: "焼き鳥", romaji: "yakitori", indonesian: "Sate ayam", category: "Daging"),
  MenuItem(japanese: "餃子", romaji: "gyōza", indonesian: "Gyoza", category: "Daging"),
  MenuItem(japanese: "焼肉", romaji: "yakiniku", indonesian: "Daging panggang", category: "Daging"),
  MenuItem(japanese: "すき焼き", romaji: "sukiyaki", indonesian: "Sukiyaki", category: "Daging"),
  MenuItem(japanese: "しゃぶしゃぶ", romaji: "shabushabu", indonesian: "Shabu-shabu", category: "Daging"),
  MenuItem(japanese: "味噌汁", romaji: "misoshiru", indonesian: "Sup miso", category: "Lainnya"),
  MenuItem(japanese: "サラダ", romaji: "sarada", indonesian: "Salad", category: "Lainnya"),
  MenuItem(japanese: "卵", romaji: "tamago", indonesian: "Telur", category: "Lainnya"),
  MenuItem(japanese: "納豆", romaji: "nattō", indonesian: "Natto (kedelai fermentasi)", category: "Lainnya"),
  MenuItem(japanese: "漬物", romaji: "tsukemono", indonesian: "Acar", category: "Lainnya"),
  MenuItem(japanese: "お好み焼き", romaji: "okonomiyaki", indonesian: "Okonomiyaki", category: "Lainnya"),
  MenuItem(japanese: "おでん", romaji: "oden", indonesian: "Oden", category: "Lainnya"),
  MenuItem(japanese: "たこ焼き", romaji: "takoyaki", indonesian: "Takoyaki", category: "Lainnya"),
  MenuItem(japanese: "お茶", romaji: "ocha", indonesian: "Teh", category: "Minuman & Manis"),
  MenuItem(japanese: "緑茶", romaji: "ryokucha", indonesian: "Teh hijau", category: "Minuman & Manis"),
  MenuItem(japanese: "コーヒー", romaji: "kōhī", indonesian: "Kopi", category: "Minuman & Manis"),
  MenuItem(japanese: "ビール", romaji: "bīru", indonesian: "Bir", category: "Minuman & Manis"),
  MenuItem(japanese: "日本酒", romaji: "nihonshu", indonesian: "Sake", category: "Minuman & Manis"),
  MenuItem(japanese: "ケーキ", romaji: "kēki", indonesian: "Kue", category: "Minuman & Manis"),
  MenuItem(japanese: "アイスクリーム", romaji: "aisukurīmu", indonesian: "Es krim", category: "Minuman & Manis"),
];

/// Daftar alergen (12 entri).
const List<AllergyItem> allergyItems = [
  AllergyItem(japanese: "卵", romaji: "tamago", indonesian: "Telur"),
  AllergyItem(japanese: "牛乳", romaji: "gyūnyū", indonesian: "Susu"),
  AllergyItem(japanese: "小麦", romaji: "komugi", indonesian: "Gandum"),
  AllergyItem(japanese: "ピーナッツ", romaji: "pīnattsu", indonesian: "Kacang tanah"),
  AllergyItem(japanese: "えび", romaji: "ebi", indonesian: "Udang"),
  AllergyItem(japanese: "かに", romaji: "kani", indonesian: "Kepiting"),
  AllergyItem(japanese: "そば", romaji: "soba", indonesian: "Soba"),
  AllergyItem(japanese: "大豆", romaji: "daizu", indonesian: "Kedelai"),
  AllergyItem(japanese: "豚肉", romaji: "butaniku", indonesian: "Babi"),
  AllergyItem(japanese: "牛肉", romaji: "gyūniku", indonesian: "Sapi"),
  AllergyItem(japanese: "鶏肉", romaji: "toriniku", indonesian: "Ayam"),
  AllergyItem(japanese: "魚", romaji: "sakana", indonesian: "Ikan"),
];

/// Pilihan diet (4 opsi; opsi kosong "Tidak ada" tidak disertakan).
const List<DietOption> dietOptions = [
  DietOption(id: "veg", japanese: "ベジタリアンです。", indonesian: "Saya vegetarian."),
  DietOption(id: "halal", japanese: "ハラールでお願いします。", indonesian: "Tolong yang halal."),
  DietOption(id: "nopork", japanese: "豚肉は食べられません。", indonesian: "Saya tidak bisa makan babi."),
  DietOption(id: "nospicy", japanese: "辛いものは苦手です。", indonesian: "Saya tidak suka pedas."),
];
