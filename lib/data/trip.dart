// Data diekstrak otomatis dari app/index.html (kota dari <option> tripCity ~baris 374; TPL baris 1909; PACK baris 1146).
// Jangan edit manual — jalankan ulang tools/extract-data.mjs bila sumber berubah.

/// Satu kota tujuan trip.
class TripCity {
  const TripCity({required this.name, required this.japanese});

  /// Nama kota (Latin).
  final String name;

  /// Nama kota (Jepang).
  final String japanese;
}

/// Satu kegiatan dalam template itinerary.
class ItineraryItem {
  const ItineraryItem({
    required this.day,
    required this.time,
    required this.activity,
  });

  /// Hari ke- (field `d`).
  final int day;

  /// Jam (field `t`, format HH:MM).
  final String time;

  /// Kegiatan (field `x`).
  final String activity;
}

/// Template itinerary per kota.
class TripTemplate {
  const TripTemplate({
    required this.cityName,
    required this.cityJapanese,
    required this.items,
  });

  /// Nama kota (Latin).
  final String cityName;

  /// Nama kota (Jepang).
  final String cityJapanese;

  /// Daftar kegiatan template.
  final List<ItineraryItem> items;
}

/// Satu barang bawaan (checklist packing).
class PackItem {
  const PackItem({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
  });

  /// Nama barang Jepang (field `ja`).
  final String japanese;

  /// Romaji (field `rm`).
  final String romaji;

  /// Arti Bahasa Indonesia (field `id`).
  final String indonesian;
}

/// Kota tujuan (8 kota).
const List<TripCity> tripCities = [
  TripCity(name: "Tokyo", japanese: "東京"),
  TripCity(name: "Kyoto", japanese: "京都"),
  TripCity(name: "Osaka", japanese: "大阪"),
  TripCity(name: "Nara", japanese: "奈良"),
  TripCity(name: "Fuji / Kawaguchiko", japanese: "富士山・河口湖"),
  TripCity(name: "Hiroshima", japanese: "広島"),
  TripCity(name: "Hokkaido", japanese: "北海道"),
  TripCity(name: "Okinawa", japanese: "沖縄"),
];

/// Template itinerary per kota (8 kota).
const List<TripTemplate> tripTemplates = [
  TripTemplate(cityName: "Tokyo", cityJapanese: "東京", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Asakusa & Kuil Senso-ji"),
    ItineraryItem(day: 1, time: "12:00", activity: "Makan siang di Nakamise"),
    ItineraryItem(day: 1, time: "15:00", activity: "Tokyo Skytree"),
    ItineraryItem(day: 1, time: "18:00", activity: "Jalan-jalan di Akihabara"),
    ItineraryItem(day: 2, time: "09:00", activity: "Shibuya & patung Hachiko"),
    ItineraryItem(day: 2, time: "11:00", activity: "Harajuku & Takeshita-dori"),
    ItineraryItem(day: 2, time: "15:00", activity: "Taman Shinjuku Gyoen"),
    ItineraryItem(day: 2, time: "18:00", activity: "Makan malam di Shinjuku"),
    ItineraryItem(day: 3, time: "09:00", activity: "Pasar Toyosu / Tsukiji"),
    ItineraryItem(day: 3, time: "12:00", activity: "Ginza"),
    ItineraryItem(day: 3, time: "15:00", activity: "Museum / TeamLab"),
    ItineraryItem(day: 3, time: "18:00", activity: "Menara Tokyo"),
  ]),
  TripTemplate(cityName: "Kyoto", cityJapanese: "京都", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Kuil Kiyomizu-dera"),
    ItineraryItem(day: 1, time: "12:00", activity: "Jalan Sannenzaka"),
    ItineraryItem(day: 1, time: "15:00", activity: "Kuil Yasaka"),
    ItineraryItem(day: 1, time: "18:00", activity: "Gion"),
    ItineraryItem(day: 2, time: "09:00", activity: "Arashiyama & hutan bambu"),
    ItineraryItem(day: 2, time: "12:00", activity: "Kuil Tenryu-ji"),
    ItineraryItem(day: 2, time: "15:00", activity: "Kereta Sagano"),
    ItineraryItem(day: 2, time: "17:00", activity: "Jembatan Togetsukyo"),
    ItineraryItem(day: 3, time: "09:00", activity: "Kuil Fushimi Inari (gerbang torii)"),
    ItineraryItem(day: 3, time: "12:00", activity: "Uji — coba matcha"),
    ItineraryItem(day: 3, time: "15:00", activity: "Istana Nijo"),
    ItineraryItem(day: 3, time: "18:00", activity: "Sungai Kamo"),
  ]),
  TripTemplate(cityName: "Osaka", cityJapanese: "大阪", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Istana Osaka"),
    ItineraryItem(day: 1, time: "12:00", activity: "Dotonbori"),
    ItineraryItem(day: 1, time: "15:00", activity: "Shinsaibashi"),
    ItineraryItem(day: 1, time: "18:00", activity: "Kuliner Dotonbori"),
    ItineraryItem(day: 2, time: "09:00", activity: "Kuil Sumiyoshi Taisha"),
    ItineraryItem(day: 2, time: "12:00", activity: "Pasar Kuromon"),
    ItineraryItem(day: 2, time: "15:00", activity: "Umeda Sky Building"),
    ItineraryItem(day: 2, time: "18:00", activity: "Shinsekai"),
  ]),
  TripTemplate(cityName: "Nara", cityJapanese: "奈良", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Taman Nara & rusa"),
    ItineraryItem(day: 1, time: "12:00", activity: "Kuil Todai-ji"),
    ItineraryItem(day: 1, time: "15:00", activity: "Kuil Kasuga Taisha"),
    ItineraryItem(day: 1, time: "17:00", activity: "Jalan-jalan Naramachi"),
    ItineraryItem(day: 2, time: "09:00", activity: "Kuil Horyu-ji"),
    ItineraryItem(day: 2, time: "12:00", activity: "Istana Heijo"),
    ItineraryItem(day: 2, time: "15:00", activity: "Gunung Wakakusa"),
  ]),
  TripTemplate(cityName: "Fuji / Kawaguchiko", cityJapanese: "富士山・河口湖", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Danau Kawaguchiko"),
    ItineraryItem(day: 1, time: "12:00", activity: "Kachi Kachi Ropeway"),
    ItineraryItem(day: 1, time: "15:00", activity: "Pagoda Chureito"),
    ItineraryItem(day: 1, time: "18:00", activity: "Onsen"),
    ItineraryItem(day: 2, time: "09:00", activity: "Oshino Hakkai"),
    ItineraryItem(day: 2, time: "12:00", activity: "Danau Yamanaka"),
    ItineraryItem(day: 2, time: "15:00", activity: "Fuji-Q Highland (opsional)"),
  ]),
  TripTemplate(cityName: "Hiroshima", cityJapanese: "広島", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Taman Perdamaian & Museum Bom Atom"),
    ItineraryItem(day: 1, time: "12:00", activity: "Istana Hiroshima"),
    ItineraryItem(day: 1, time: "15:00", activity: "Jalan Hondori"),
    ItineraryItem(day: 1, time: "18:00", activity: "Okonomiyaki"),
    ItineraryItem(day: 2, time: "09:00", activity: "Kapal ke Miyajima"),
    ItineraryItem(day: 2, time: "11:00", activity: "Torii terapung & Kuil Itsukushima"),
    ItineraryItem(day: 2, time: "15:00", activity: "Gunung Misen"),
    ItineraryItem(day: 2, time: "17:00", activity: "Kembali ke Hiroshima"),
  ]),
  TripTemplate(cityName: "Hokkaido", cityJapanese: "北海道", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Sapporo & Menara Jam"),
    ItineraryItem(day: 1, time: "12:00", activity: "Pasar Nijo"),
    ItineraryItem(day: 1, time: "15:00", activity: "Taman Odori"),
    ItineraryItem(day: 1, time: "18:00", activity: "Ramen Sapporo"),
    ItineraryItem(day: 2, time: "09:00", activity: "Otaru & kanal"),
    ItineraryItem(day: 2, time: "12:00", activity: "Museum Kotak Musik"),
    ItineraryItem(day: 2, time: "15:00", activity: "Bukit Tenguyama"),
    ItineraryItem(day: 2, time: "18:00", activity: "Sushi Otaru"),
    ItineraryItem(day: 3, time: "09:00", activity: "Biei & kolam biru"),
    ItineraryItem(day: 3, time: "12:00", activity: "Ladang bunga Furano"),
    ItineraryItem(day: 3, time: "15:00", activity: "Onsen"),
    ItineraryItem(day: 3, time: "18:00", activity: "Kembali ke Sapporo"),
  ]),
  TripTemplate(cityName: "Okinawa", cityJapanese: "沖縄", items: [
    ItineraryItem(day: 1, time: "09:00", activity: "Istana Shuri"),
    ItineraryItem(day: 1, time: "12:00", activity: "Kokusai-dori"),
    ItineraryItem(day: 1, time: "15:00", activity: "Pantai Naminoue"),
    ItineraryItem(day: 1, time: "18:00", activity: "Kuliner Okinawa"),
    ItineraryItem(day: 2, time: "09:00", activity: "Akuarium Churaumi"),
    ItineraryItem(day: 2, time: "12:00", activity: "Cape Manzamo"),
    ItineraryItem(day: 2, time: "15:00", activity: "Pantai Emerald"),
    ItineraryItem(day: 2, time: "18:00", activity: "Kembali ke Naha"),
    ItineraryItem(day: 3, time: "09:00", activity: "Pulau Zamami / snorkeling"),
    ItineraryItem(day: 3, time: "12:00", activity: "Pantai"),
    ItineraryItem(day: 3, time: "15:00", activity: "Pasar Makishi"),
    ItineraryItem(day: 3, time: "18:00", activity: "Oleh-oleh"),
  ]),
];

/// Checklist packing (10 item).
const List<PackItem> packingList = [
  PackItem(japanese: "パスポート", romaji: "pasupōto", indonesian: "Paspor"),
  PackItem(japanese: "充電器", romaji: "jūdenki", indonesian: "Charger"),
  PackItem(japanese: "薬", romaji: "kusuri", indonesian: "Obat"),
  PackItem(japanese: "服", romaji: "fuku", indonesian: "Pakaian"),
  PackItem(japanese: "雨傘", romaji: "amagasa", indonesian: "Payung"),
  PackItem(japanese: "現金", romaji: "genkin", indonesian: "Uang tunai"),
  PackItem(japanese: "カメラ", romaji: "kamera", indonesian: "Kamera"),
  PackItem(japanese: "歯ブラシ", romaji: "haburashi", indonesian: "Sikat gigi"),
  PackItem(japanese: "タオル", romaji: "taoru", indonesian: "Handuk"),
  PackItem(japanese: "地図", romaji: "chizu", indonesian: "Peta / panduan"),
];
