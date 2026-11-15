// Data diekstrak otomatis dari app/index.html (KONBINI baris 1048).
// Jangan edit manual — jalankan ulang tools/extract-data.mjs bila sumber berubah.

/// Satu item konbini.
class KonbiniItem {
  const KonbiniItem({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
    required this.category,
  });

  /// Nama Jepang (field `ja`).
  final String japanese;

  /// Romaji (field `rm`).
  final String romaji;

  /// Arti Bahasa Indonesia (field `id`).
  final String indonesian;

  /// Kategori (field `c`).
  final String category;
}

/// Daftar konbini (33 item).
const List<KonbiniItem> konbiniItems = [
  KonbiniItem(japanese: "おにぎり", romaji: "onigiri", indonesian: "Nasi kepal", category: "Makanan"),
  KonbiniItem(japanese: "お弁当", romaji: "obentō", indonesian: "Nasi kotak", category: "Makanan"),
  KonbiniItem(japanese: "サンドイッチ", romaji: "sandoitchi", indonesian: "Roti lapis", category: "Makanan"),
  KonbiniItem(japanese: "パン", romaji: "pan", indonesian: "Roti", category: "Makanan"),
  KonbiniItem(japanese: "おでん", romaji: "oden", indonesian: "Oden (rebusan kuah)", category: "Makanan"),
  KonbiniItem(japanese: "肉まん", romaji: "nikuman", indonesian: "Bakpao daging", category: "Makanan"),
  KonbiniItem(japanese: "からあげ", romaji: "karaage", indonesian: "Ayam goreng", category: "Makanan"),
  KonbiniItem(japanese: "カップラーメン", romaji: "kappu rāmen", indonesian: "Mi instan cup", category: "Makanan"),
  KonbiniItem(japanese: "カレーパン", romaji: "karē pan", indonesian: "Roti isi kari", category: "Makanan"),
  KonbiniItem(japanese: "メロンパン", romaji: "meron pan", indonesian: "Roti melon", category: "Makanan"),
  KonbiniItem(japanese: "どら焼き", romaji: "dorayaki", indonesian: "Dorayaki", category: "Makanan"),
  KonbiniItem(japanese: "団子", romaji: "dango", indonesian: "Dango (kue beras tusuk)", category: "Makanan"),
  KonbiniItem(japanese: "せんべい", romaji: "senbei", indonesian: "Kerupuk beras", category: "Makanan"),
  KonbiniItem(japanese: "お菓子", romaji: "okashi", indonesian: "Camilan · permen", category: "Makanan"),
  KonbiniItem(japanese: "チョコレート", romaji: "chokorēto", indonesian: "Cokelat", category: "Makanan"),
  KonbiniItem(japanese: "サラダ", romaji: "sarada", indonesian: "Salad", category: "Makanan"),
  KonbiniItem(japanese: "たまご", romaji: "tamago", indonesian: "Telur", category: "Makanan"),
  KonbiniItem(japanese: "ゆで卵", romaji: "yude tamago", indonesian: "Telur rebus", category: "Makanan"),
  KonbiniItem(japanese: "プリン", romaji: "purin", indonesian: "Puding", category: "Makanan"),
  KonbiniItem(japanese: "ヨーグルト", romaji: "yōguruto", indonesian: "Yoghurt", category: "Makanan"),
  KonbiniItem(japanese: "アイスクリーム", romaji: "aisukurīmu", indonesian: "Es krim", category: "Makanan"),
  KonbiniItem(japanese: "お茶", romaji: "ocha", indonesian: "Teh", category: "Minuman"),
  KonbiniItem(japanese: "緑茶", romaji: "ryokucha", indonesian: "Teh hijau", category: "Minuman"),
  KonbiniItem(japanese: "コーヒー", romaji: "kōhī", indonesian: "Kopi", category: "Minuman"),
  KonbiniItem(japanese: "牛乳", romaji: "gyūnyū", indonesian: "Susu", category: "Minuman"),
  KonbiniItem(japanese: "水", romaji: "mizu", indonesian: "Air mineral", category: "Minuman"),
  KonbiniItem(japanese: "ジュース", romaji: "jūsu", indonesian: "Jus", category: "Minuman"),
  KonbiniItem(japanese: "ビール", romaji: "bīru", indonesian: "Bir", category: "Minuman"),
  KonbiniItem(japanese: "ガム", romaji: "gamu", indonesian: "Permen karet", category: "Lainnya"),
  KonbiniItem(japanese: "ティッシュ", romaji: "tisshu", indonesian: "Tisu", category: "Lainnya"),
  KonbiniItem(japanese: "カイロ", romaji: "kairo", indonesian: "Penghangat tangan", category: "Lainnya"),
  KonbiniItem(japanese: "雨傘", romaji: "amagasa", indonesian: "Payung", category: "Lainnya"),
  KonbiniItem(japanese: "充電器", romaji: "jūdenki", indonesian: "Charger", category: "Lainnya"),
];
