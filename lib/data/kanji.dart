// Data kartu kanji Materi (ditulis manual, gaya Goukaku).
// BAB 1 = kanji dasar N5 (satu radikal), BAB 2 = kanji gabungan (dua komponen).
// Level lain (N4–N1) dan BAB berikutnya menyusul.

/// Satu komponen penyusun kanji (bushu/radikal atau komponen lain).
class KanjiComponent {
  const KanjiComponent({
    required this.kanji,
    required this.reading,
    required this.arti,
    required this.isBushu,
    required this.position,
    required this.theme,
    required this.caraIngat,
  });

  /// Kanji komponen (mis. 亻).
  final String kanji;

  /// Bacaan komponen (mis. にんべん).
  final String reading;

  /// Arti komponen (mis. orang).
  final String arti;

  /// true = bushu (radikal utama), false = komponen lain.
  final bool isBushu;

  /// Posisi di dalam kanji ('Di sisi kiri' / 'Di sisi kanan' / '').
  final String position;

  /// Tema umum kanji dengan komponen ini.
  final String theme;

  /// Cara mengingat komponen ini.
  final String caraIngat;
}

/// Satu contoh kosakata yang memakai kanji ini.
class ContohKata {
  const ContohKata({
    required this.kata,
    required this.reading,
    required this.arti,
  });

  final String kata;
  final String reading;
  final String arti;
}

/// Satu kartu kanji.
class KanjiCard {
  const KanjiCard({
    required this.kanji,
    required this.on,
    required this.kun,
    required this.arti,
    required this.bab,
    required this.components,
    required this.mnemonic,
    this.similar,
    this.similarDiff,
    required this.contoh,
  });

  final String kanji;

  /// On'yomi, dipisah '・' (mis. 'ニチ・ジツ').
  final String on;

  /// Kun'yomi, dipisah '・' ('' bila tidak ada).
  final String kun;

  /// Arti Bahasa Indonesia.
  final String arti;

  /// Nomor BAB (1 atau 2).
  final int bab;

  /// Komponen penyusun (bushu + komponen lain).
  final List<KanjiComponent> components;

  /// Cara mengingat kanji ini (ilustrasi).
  final String mnemonic;

  /// Kanji mirip (bila ada).
  final String? similar;

  /// Bedanya dengan kanji mirip.
  final String? similarDiff;

  /// Contoh kosakata.
  final List<ContohKata> contoh;
}

/// Judul tiap BAB kanji.
class KanjiBab {
  const KanjiBab({required this.nomor, required this.judul, this.bushu});

  final int nomor;
  final String judul;

  /// Radikal utama BAB ini (bila satu tema).
  final String? bushu;
}

const List<KanjiBab> kanjiBabs = [
  KanjiBab(nomor: 1, judul: 'Kanji Dasar'),
  KanjiBab(nomor: 2, judul: 'Kanji Gabungan', bushu: '木'),
];

const List<KanjiCard> kanjiCards = [
  // ---------------- BAB 1: Kanji Dasar ----------------
  KanjiCard(
    kanji: '日',
    on: 'ニチ・ジツ',
    kun: 'ひ・か',
    arti: 'matahari, hari',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '日',
        reading: 'にち',
        arti: 'matahari, hari',
        isBushu: true,
        position: '',
        theme: 'waktu: hari, tanggal, siang',
        caraIngat: 'Lingkaran matahari dengan satu garis di tengah',
      ),
    ],
    mnemonic: 'Matahari di langit dengan sinar di tengahnya',
    similar: '白',
    similarDiff: '白 punya satu goresan miring di atas; 日 tidak',
    contoh: [
      ContohKata(kata: '日曜日', reading: 'にちようび', arti: 'hari Minggu'),
      ContohKata(kata: '日本', reading: 'にほん', arti: 'Jepang'),
      ContohKata(kata: '今日', reading: 'きょう', arti: 'hari ini'),
    ],
  ),
  KanjiCard(
    kanji: '月',
    on: 'ゲツ・ガツ',
    kun: 'つき',
    arti: 'bulan',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '月',
        reading: 'つき',
        arti: 'bulan',
        isBushu: true,
        position: '',
        theme: 'waktu: bulan, malam',
        caraIngat: 'Bulan sabit di langit malam',
      ),
    ],
    mnemonic: 'Bulan sabit di langit malam',
    similar: '用',
    similarDiff: '用 punya satu goresan tambahan di atas 月',
    contoh: [
      ContohKata(kata: '月曜日', reading: 'げつようび', arti: 'hari Senin'),
      ContohKata(kata: '一月', reading: 'いちがつ', arti: 'Januari'),
      ContohKata(kata: '月', reading: 'つき', arti: 'bulan'),
    ],
  ),
  KanjiCard(
    kanji: '火',
    on: 'カ',
    kun: 'ひ',
    arti: 'api',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '火',
        reading: 'ひ',
        arti: 'api',
        isBushu: true,
        position: '',
        theme: 'api, panas, cahaya',
        caraIngat: 'Api yang menyala dengan lidah-lidah apinya',
      ),
    ],
    mnemonic: 'Api yang menyala dengan lidah-lidah apinya',
    contoh: [
      ContohKata(kata: '火曜日', reading: 'かようび', arti: 'hari Selasa'),
      ContohKata(kata: '火', reading: 'ひ', arti: 'api'),
      ContohKata(kata: '火山', reading: 'かざん', arti: 'gunung berapi'),
    ],
  ),
  KanjiCard(
    kanji: '水',
    on: 'スイ',
    kun: 'みず',
    arti: 'air',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '水',
        reading: 'みず',
        arti: 'air',
        isBushu: true,
        position: '',
        theme: 'air, cairan',
        caraIngat: 'Air mengalir dengan percikannya',
      ),
    ],
    mnemonic: 'Air mengalir dengan percikannya',
    similar: '氷',
    similarDiff: '氷 adalah 水 yang membeku, dengan satu goresan tambahan',
    contoh: [
      ContohKata(kata: '水曜日', reading: 'すいようび', arti: 'hari Rabu'),
      ContohKata(kata: '水', reading: 'みず', arti: 'air'),
      ContohKata(kata: '水道', reading: 'すいどう', arti: 'saluran air'),
    ],
  ),
  KanjiCard(
    kanji: '木',
    on: 'モク・ボク',
    kun: 'き・こ',
    arti: 'pohon, kayu',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '木',
        reading: 'き',
        arti: 'pohon',
        isBushu: true,
        position: '',
        theme: 'tumbuhan, kayu',
        caraIngat: 'Pohon dengan batang dan dahan-dahannya',
      ),
    ],
    mnemonic: 'Pohon dengan batang dan dahan-dahannya',
    similar: '本',
    similarDiff: '本 adalah 木 dengan satu goresan akar di bawah; 木 tidak punya',
    contoh: [
      ContohKata(kata: '木曜日', reading: 'もくようび', arti: 'hari Kamis'),
      ContohKata(kata: '木', reading: 'き', arti: 'pohon'),
      ContohKata(kata: '木材', reading: 'もくざい', arti: 'kayu, bahan kayu'),
    ],
  ),
  KanjiCard(
    kanji: '金',
    on: 'キン',
    kun: 'かね',
    arti: 'emas, uang, logam',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '金',
        reading: 'かね',
        arti: 'emas, uang',
        isBushu: true,
        position: '',
        theme: 'logam, uang',
        caraIngat: 'Logam emas yang berkilau',
      ),
    ],
    mnemonic: 'Logam emas yang berkilau',
    contoh: [
      ContohKata(kata: '金曜日', reading: 'きんようび', arti: 'hari Jumat'),
      ContohKata(kata: 'お金', reading: 'おかね', arti: 'uang'),
      ContohKata(kata: '金色', reading: 'きんいろ', arti: 'warna emas'),
    ],
  ),
  KanjiCard(
    kanji: '土',
    on: 'ド・ト',
    kun: 'つち',
    arti: 'tanah',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '土',
        reading: 'つち',
        arti: 'tanah',
        isBushu: true,
        position: '',
        theme: 'tanah, bumi',
        caraIngat: 'Tanah dengan tumbuhan yang tumbuh di atasnya',
      ),
    ],
    mnemonic: 'Tanah dengan tumbuhan yang tumbuh di atasnya',
    similar: '士',
    similarDiff:
        '士 punya goresan atas lebih panjang dari goresan bawah; 土 sebaliknya',
    contoh: [
      ContohKata(kata: '土曜日', reading: 'どようび', arti: 'hari Sabtu'),
      ContohKata(kata: '土', reading: 'つち', arti: 'tanah'),
      ContohKata(kata: '土地', reading: 'とち', arti: 'tanah, lahan'),
    ],
  ),
  KanjiCard(
    kanji: '山',
    on: 'サン',
    kun: 'やま',
    arti: 'gunung',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '山',
        reading: 'やま',
        arti: 'gunung',
        isBushu: true,
        position: '',
        theme: 'gunung, tinggi',
        caraIngat: 'Tiga puncak gunung',
      ),
    ],
    mnemonic: 'Tiga puncak gunung',
    contoh: [
      ContohKata(kata: '山', reading: 'やま', arti: 'gunung'),
      ContohKata(kata: '富士山', reading: 'ふじさん', arti: 'Gunung Fuji'),
      ContohKata(kata: '山田', reading: 'やまだ', arti: 'nama keluarga Yamada'),
    ],
  ),
  KanjiCard(
    kanji: '川',
    on: 'セン',
    kun: 'かわ',
    arti: 'sungai',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '川',
        reading: 'かわ',
        arti: 'sungai',
        isBushu: true,
        position: '',
        theme: 'air mengalir, sungai',
        caraIngat: 'Tiga aliran sungai yang mengalir',
      ),
    ],
    mnemonic: 'Tiga aliran sungai yang mengalir',
    similar: '州',
    similarDiff: '州 punya titik-titik tambahan di antara aliran 川',
    contoh: [
      ContohKata(kata: '川', reading: 'かわ', arti: 'sungai'),
      ContohKata(kata: '川口', reading: 'かわぐち', arti: 'Kawaguchi (nama tempat)'),
      ContohKata(kata: '小川', reading: 'おがわ', arti: 'sungai kecil'),
    ],
  ),
  KanjiCard(
    kanji: '田',
    on: 'デン',
    kun: 'た',
    arti: 'sawah',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '田',
        reading: 'た',
        arti: 'sawah',
        isBushu: true,
        position: '',
        theme: 'sawah, ladang',
        caraIngat: 'Sawah yang dipetak-petak',
      ),
    ],
    mnemonic: 'Sawah yang dipetak-petak',
    similar: '由',
    similarDiff:
        '由 punya satu goresan vertikal yang keluar dari bawah; 田 tertutup rapi',
    contoh: [
      ContohKata(kata: '田', reading: 'た', arti: 'sawah'),
      ContohKata(kata: '田中', reading: 'たなか', arti: 'nama keluarga Tanaka'),
      ContohKata(kata: '水田', reading: 'すいでん', arti: 'sawah berair'),
    ],
  ),
  KanjiCard(
    kanji: '人',
    on: 'ジン・ニン',
    kun: 'ひと',
    arti: 'orang',
    bab: 1,
    components: [
      KanjiComponent(
        kanji: '人',
        reading: 'ひと',
        arti: 'orang',
        isBushu: true,
        position: '',
        theme: 'manusia: sifat, peran, tindakan',
        caraIngat: 'Orang berdiri dari samping',
      ),
    ],
    mnemonic: 'Orang berdiri dari samping',
    similar: '入',
    similarDiff:
        '入 punya goresan kanan yang lebih panjang; 人 goresan kirinya yang lebih panjang',
    contoh: [
      ContohKata(kata: '人', reading: 'ひと', arti: 'orang'),
      ContohKata(kata: '日本人', reading: 'にほんじん', arti: 'orang Jepang'),
      ContohKata(kata: '人気', reading: 'にんき', arti: 'populer'),
    ],
  ),

  // ---------------- BAB 2: Kanji Gabungan ----------------
  KanjiCard(
    kanji: '明',
    on: 'メイ・ミョウ',
    kun: 'あか・あき',
    arti: 'terang, jelas',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '日',
        reading: 'にち',
        arti: 'matahari, hari',
        isBushu: true,
        position: 'Di sisi kiri',
        theme: 'waktu: hari, tanggal, siang',
        caraIngat: 'Lingkaran matahari dengan satu garis di tengah',
      ),
      KanjiComponent(
        kanji: '月',
        reading: 'つき',
        arti: 'bulan',
        isBushu: false,
        position: 'Di sisi kanan',
        theme: 'waktu: bulan, malam',
        caraIngat: 'Bulan sabit di langit malam',
      ),
    ],
    mnemonic: 'Matahari dan bulan bersinar bersama = terang',
    similar: '朋',
    similarDiff: '朋 punya dua 月; 明 punya 日 dan 月',
    contoh: [
      ContohKata(kata: '明日', reading: 'あす', arti: 'besok'),
      ContohKata(kata: '明るい', reading: 'あかるい', arti: 'terang'),
      ContohKata(kata: '説明', reading: 'せつめい', arti: 'penjelasan'),
    ],
  ),
  KanjiCard(
    kanji: '林',
    on: 'リン',
    kun: 'はやし',
    arti: 'hutan kecil',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '木',
        reading: 'き',
        arti: 'pohon',
        isBushu: true,
        position: 'Di sisi kiri dan kanan',
        theme: 'tumbuhan, kayu',
        caraIngat: 'Pohon dengan batang dan dahan-dahannya',
      ),
    ],
    mnemonic: 'Dua pohon berdampingan = hutan kecil',
    similar: '森',
    similarDiff: '森 punya tiga 木; 林 hanya dua',
    contoh: [
      ContohKata(kata: '林', reading: 'はやし', arti: 'hutan kecil'),
      ContohKata(kata: '林道', reading: 'りんどう', arti: 'jalan hutan'),
      ContohKata(kata: '森林', reading: 'しんりん', arti: 'hutan'),
    ],
  ),
  KanjiCard(
    kanji: '森',
    on: 'シン',
    kun: 'もり',
    arti: 'hutan',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '木',
        reading: 'き',
        arti: 'pohon',
        isBushu: true,
        position: 'Tiga kali (kiri, kanan, bawah)',
        theme: 'tumbuhan, kayu',
        caraIngat: 'Pohon dengan batang dan dahan-dahannya',
      ),
    ],
    mnemonic: 'Tiga pohon = hutan besar',
    similar: '林',
    similarDiff: '林 hanya dua 木; 森 tiga',
    contoh: [
      ContohKata(kata: '森', reading: 'もり', arti: 'hutan'),
      ContohKata(kata: '森林', reading: 'しんりん', arti: 'hutan'),
      ContohKata(kata: '森田', reading: 'もりた', arti: 'nama keluarga Morita'),
    ],
  ),
  KanjiCard(
    kanji: '本',
    on: 'ホン',
    kun: 'もと',
    arti: 'buku, asal',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '木',
        reading: 'き',
        arti: 'pohon',
        isBushu: true,
        position: '',
        theme: 'tumbuhan, kayu',
        caraIngat: 'Pohon dengan batang dan dahan-dahannya',
      ),
    ],
    mnemonic: 'Pohon dengan akar = asal mula; buku berasal dari kayu',
    similar: '木',
    similarDiff: '木 tidak punya goresan akar di bawah; 本 punya',
    contoh: [
      ContohKata(kata: '本', reading: 'ほん', arti: 'buku'),
      ContohKata(kata: '日本', reading: 'にほん', arti: 'Jepang'),
      ContohKata(kata: '本当', reading: 'ほんとう', arti: 'benar, sungguh'),
    ],
  ),
  KanjiCard(
    kanji: '休',
    on: 'キュウ',
    kun: 'やす',
    arti: 'istirahat',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '亻',
        reading: 'にんべん',
        arti: 'orang',
        isBushu: true,
        position: 'Di sisi kiri',
        theme: 'manusia: sifat, peran, tindakan',
        caraIngat: 'Orang berdiri dari samping',
      ),
      KanjiComponent(
        kanji: '木',
        reading: 'き',
        arti: 'pohon',
        isBushu: false,
        position: 'Di sisi kanan',
        theme: 'tumbuhan, kayu',
        caraIngat: 'Pohon dengan batang dan dahan-dahannya',
      ),
    ],
    mnemonic: 'Orang bersandar di pohon = istirahat',
    similar: '体',
    similarDiff: '体 juga punya 亻 di kiri, tapi kanannya 本 bukan 木',
    contoh: [
      ContohKata(kata: '休み', reading: 'やすみ', arti: 'libur, istirahat'),
      ContohKata(kata: '休日', reading: 'きゅうじつ', arti: 'hari libur'),
      ContohKata(kata: '夏休み', reading: 'なつやすみ', arti: 'liburan musim panas'),
    ],
  ),
  KanjiCard(
    kanji: '体',
    on: 'タイ・テイ',
    kun: 'からだ',
    arti: 'tubuh',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '亻',
        reading: 'にんべん',
        arti: 'orang',
        isBushu: true,
        position: 'Di sisi kiri',
        theme: 'manusia: sifat, peran, tindakan',
        caraIngat: 'Orang berdiri dari samping',
      ),
      KanjiComponent(
        kanji: '本',
        reading: 'ほん',
        arti: 'buku, asal',
        isBushu: false,
        position: 'Di sisi kanan',
        theme: 'buku, asal mula',
        caraIngat: 'Pohon dengan akar = asal mula',
      ),
    ],
    mnemonic: 'Orang dengan akar tubuhnya = badan',
    similar: '休',
    similarDiff: '休 kanannya 木; 体 kanannya 本',
    contoh: [
      ContohKata(kata: '体', reading: 'からだ', arti: 'tubuh'),
      ContohKata(kata: '体重', reading: 'たいじゅう', arti: 'berat badan'),
      ContohKata(kata: '体育', reading: 'たいいく', arti: 'olahraga'),
    ],
  ),
  KanjiCard(
    kanji: '白',
    on: 'ハク・ビャク',
    kun: 'しろ・しら',
    arti: 'putih',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '白',
        reading: 'はく',
        arti: 'putih',
        isBushu: true,
        position: '',
        theme: 'warna: putih, terang',
        caraIngat: 'Matahari dengan satu sinar = putih terang',
      ),
    ],
    mnemonic: 'Matahari dengan satu sinar = putih terang',
    similar: '日',
    similarDiff: '日 tidak punya goresan miring di atas; 白 punya',
    contoh: [
      ContohKata(kata: '白', reading: 'しろ', arti: 'putih'),
      ContohKata(kata: '白い', reading: 'しろい', arti: 'putih'),
      ContohKata(kata: '白鳥', reading: 'はくちょう', arti: 'angsa'),
    ],
  ),
  KanjiCard(
    kanji: '早',
    on: 'ソウ・サッ',
    kun: 'はや',
    arti: 'cepat, pagi',
    bab: 2,
    components: [
      KanjiComponent(
        kanji: '日',
        reading: 'にち',
        arti: 'matahari, hari',
        isBushu: true,
        position: 'Di atas',
        theme: 'waktu: hari, tanggal, siang',
        caraIngat: 'Lingkaran matahari dengan satu garis di tengah',
      ),
    ],
    mnemonic: 'Matahari baru naik sepuluh = masih pagi',
    contoh: [
      ContohKata(kata: '早い', reading: 'はやい', arti: 'cepat, awal'),
      ContohKata(kata: '早朝', reading: 'そうちょう', arti: 'pagi-pagi sekali'),
      ContohKata(kata: '早く', reading: 'はやく', arti: 'cepat-cepat'),
    ],
  ),
];

/// Kanji dalam satu BAB.
List<KanjiCard> kanjiByBab(int bab) =>
    kanjiCards.where((k) => k.bab == bab).toList();

/// Kanji lain di deck yang memakai komponen [componentKanji]
/// (tidak termasuk kanji itu sendiri).
List<KanjiCard> kanjiWithComponent(String componentKanji, String self) =>
    kanjiCards
        .where((k) =>
            k.kanji != self &&
            k.components.any((c) => c.kanji == componentKanji))
        .toList();
