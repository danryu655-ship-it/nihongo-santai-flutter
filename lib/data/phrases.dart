// Data diekstrak otomatis dari app/index.html (FRASA baris 979).
// Jangan edit manual — jalankan ulang tools/extract-data.mjs bila sumber berubah.

/// Satu frasa perjalanan.
class PhraseEntry {
  const PhraseEntry({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
    this.english,
    required this.category,
  });

  /// Kalimat Jepang (field `ja`).
  final String japanese;

  /// Romaji (field `rm`).
  final String romaji;

  /// Arti Bahasa Indonesia (field `id`).
  final String indonesian;

  /// Arti Bahasa Inggris (field `en`); null bila tidak ada di sumber.
  final String? english;

  /// Kategori frasa (field `c`).
  final String category;
}

/// Frasa perjalanan (67 entri).
const List<PhraseEntry> phrases = [
  PhraseEntry(japanese: "おはようございます", romaji: "ohayō gozaimasu", indonesian: "Selamat pagi", english: "Good morning", category: "Salam"),
  PhraseEntry(japanese: "こんにちは", romaji: "konnichiwa", indonesian: "Selamat siang · Halo", english: "Hello, good afternoon", category: "Salam"),
  PhraseEntry(japanese: "こんばんは", romaji: "konbanwa", indonesian: "Selamat malam", english: "Good evening", category: "Salam"),
  PhraseEntry(japanese: "ありがとうございます", romaji: "arigatō gozaimasu", indonesian: "Terima kasih", english: null, category: "Salam"),
  PhraseEntry(japanese: "はじめまして", romaji: "hajimemashite", indonesian: "Senang bertemu dengan Anda", english: null, category: "Salam"),
  PhraseEntry(japanese: "さようなら", romaji: "sayōnara", indonesian: "Selamat tinggal", english: "Goodbye", category: "Salam"),
  PhraseEntry(japanese: "おやすみなさい", romaji: "oyasumi nasai", indonesian: "Selamat tidur", english: null, category: "Salam"),
  PhraseEntry(japanese: "すみません", romaji: "sumimasen", indonesian: "Permisi · Maaf", english: null, category: "Salam"),
  PhraseEntry(japanese: "トイレはどこですか", romaji: "toire wa doko desu ka", indonesian: "Di mana toilet?", english: "Where is the toilet?", category: "Tanya Arah"),
  PhraseEntry(japanese: "駅はどこですか", romaji: "eki wa doko desu ka", indonesian: "Di mana stasiun?", english: "Where is the station?", category: "Tanya Arah"),
  PhraseEntry(japanese: "ここはどこですか", romaji: "koko wa doko desu ka", indonesian: "Ini di mana?", english: "Where is this?", category: "Tanya Arah"),
  PhraseEntry(japanese: "右ですか、左ですか", romaji: "migi desu ka, hidari desu ka", indonesian: "Kanan atau kiri?", english: null, category: "Tanya Arah"),
  PhraseEntry(japanese: "まっすぐですか", romaji: "massugu desu ka", indonesian: "Lurus saja?", english: null, category: "Tanya Arah"),
  PhraseEntry(japanese: "英語は話せますか", romaji: "eigo wa hanasemasu ka", indonesian: "Bisa bicara bahasa Inggris?", english: null, category: "Tanya Arah"),
  PhraseEntry(japanese: "いくらですか", romaji: "ikura desu ka", indonesian: "Berapa harganya?", english: "How much is it?", category: "Belanja"),
  PhraseEntry(japanese: "これをください", romaji: "kore o kudasai", indonesian: "Saya mau yang ini", english: "This one, please", category: "Belanja"),
  PhraseEntry(japanese: "カードは使えますか", romaji: "kādo wa tsukaemasu ka", indonesian: "Bisa pakai kartu?", english: null, category: "Belanja"),
  PhraseEntry(japanese: "袋はいりません", romaji: "fukuro wa irimasen", indonesian: "Tidak perlu kantong", english: null, category: "Belanja"),
  PhraseEntry(japanese: "レシートをください", romaji: "reshīto o kudasai", indonesian: "Minta struknya", english: null, category: "Belanja"),
  PhraseEntry(japanese: "メニューをください", romaji: "menyū o kudasai", indonesian: "Minta menunya", english: "The menu, please", category: "Restoran"),
  PhraseEntry(japanese: "水をください", romaji: "mizu o kudasai", indonesian: "Minta air putih", english: "Water, please", category: "Restoran"),
  PhraseEntry(japanese: "すみません、注文をお願いします", romaji: "sumimasen, chūmon o onegai shimasu", indonesian: "Permisi, saya mau pesan", english: null, category: "Restoran"),
  PhraseEntry(japanese: "おいしいです", romaji: "oishii desu", indonesian: "Enak sekali", english: "It’s delicious", category: "Restoran"),
  PhraseEntry(japanese: "お会計をお願いします", romaji: "okaikei o onegai shimasu", indonesian: "Minta bonnya", english: "The bill, please", category: "Restoran"),
  PhraseEntry(japanese: "助けてください", romaji: "tasukete kudasai", indonesian: "Tolong saya!", english: "Help me, please!", category: "Darurat"),
  PhraseEntry(japanese: "病院はどこですか", romaji: "byōin wa doko desu ka", indonesian: "Di mana rumah sakit?", english: "Where is the hospital?", category: "Darurat"),
  PhraseEntry(japanese: "警察を呼んでください", romaji: "keisatsu o yonde kudasai", indonesian: "Tolong panggil polisi", english: "Please call the police", category: "Darurat"),
  PhraseEntry(japanese: "具合が悪いです", romaji: "guai ga warui desu", indonesian: "Saya tidak enak badan", english: "I feel sick", category: "Darurat"),
  PhraseEntry(japanese: "薬局はどこですか", romaji: "yakkyoku wa doko desu ka", indonesian: "Di mana apotek?", english: null, category: "Darurat"),
  PhraseEntry(japanese: "ごめんなさい", romaji: "gomen nasai", indonesian: "Maafkan saya", english: null, category: "Minta Maaf"),
  PhraseEntry(japanese: "申し訳ありません", romaji: "mōshiwake arimasen", indonesian: "Saya benar-benar minta maaf", english: null, category: "Minta Maaf"),
  PhraseEntry(japanese: "わかりません", romaji: "wakarimasen", indonesian: "Saya tidak mengerti", english: null, category: "Minta Maaf"),
  PhraseEntry(japanese: "もう一度お願いします", romaji: "mō ichido onegai shimasu", indonesian: "Tolong ulangi sekali lagi", english: null, category: "Minta Maaf"),
  PhraseEntry(japanese: "はじめまして。わたしはダニエルです。", romaji: "hajimemashite. watashi wa danieru desu.", indonesian: "Senang bertemu denganmu. Saya Daniel.", english: "Nice to meet you. I’m Daniel.", category: "Salam"),
  PhraseEntry(japanese: "おげんきですか", romaji: "ogenki desu ka", indonesian: "Apa kabar?", english: "How are you?", category: "Salam"),
  PhraseEntry(japanese: "げんきです、ありがとう", romaji: "genki desu, arigatou", indonesian: "Saya baik, terima kasih", english: "I’m fine, thank you", category: "Salam"),
  PhraseEntry(japanese: "またあした", romaji: "mata ashita", indonesian: "Sampai besok", english: "See you tomorrow", category: "Salam"),
  PhraseEntry(japanese: "チェックインをおねがいします", romaji: "chekkuin o onegai shimasu", indonesian: "Tolong check-in", english: "Check-in, please", category: "Bandara"),
  PhraseEntry(japanese: "パスポートはここです", romaji: "pasupooto wa koko desu", indonesian: "Ini paspor saya", english: "Here is my passport", category: "Bandara"),
  PhraseEntry(japanese: "荷物はひとつだけです", romaji: "nimotsu wa hitotsu dake desu", indonesian: "Bagasi saya hanya satu", english: "I have only one bag", category: "Bandara"),
  PhraseEntry(japanese: "飛行機は何時に出発しますか", romaji: "hikouki wa nanji ni shuppatsu shimasu ka", indonesian: "Pesawat berangkat jam berapa?", english: "What time does the plane depart?", category: "Bandara"),
  PhraseEntry(japanese: "搭乗口はどこですか", romaji: "toujouguchi wa doko desu ka", indonesian: "Gerbang keberangkatan di mana?", english: "Where is the boarding gate?", category: "Bandara"),
  PhraseEntry(japanese: "遅れていますか", romaji: "okurete imasu ka", indonesian: "Apakah terlambat?", english: "Is it delayed?", category: "Bandara"),
  PhraseEntry(japanese: "窓側の席をおねがいします", romaji: "madogawa no seki o onegai shimasu", indonesian: "Saya minta kursi dekat jendela", english: "A window seat, please", category: "Bandara"),
  PhraseEntry(japanese: "予約しています", romaji: "yoyaku shite imasu", indonesian: "Saya sudah reservasi", english: "I have a reservation", category: "Hotel"),
  PhraseEntry(japanese: "部屋の鍵をください", romaji: "heya no kagi o kudasai", indonesian: "Tolong kunci kamarnya", english: "The room key, please", category: "Hotel"),
  PhraseEntry(japanese: "朝ご飯は何時からですか", romaji: "asagohan wa nanji kara desu ka", indonesian: "Sarapan mulai jam berapa?", english: "What time does breakfast start?", category: "Hotel"),
  PhraseEntry(japanese: "チェックアウトは何時までですか", romaji: "chekkuauto wa nanji made desu ka", indonesian: "Check-out sampai jam berapa?", english: "Until what time is check-out?", category: "Hotel"),
  PhraseEntry(japanese: "お風呂はどこですか", romaji: "ofuro wa doko desu ka", indonesian: "Kamar mandi di mana?", english: "Where is the bath?", category: "Hotel"),
  PhraseEntry(japanese: "タオルをください", romaji: "taoru o kudasai", indonesian: "Tolong handuk", english: "A towel, please", category: "Hotel"),
  PhraseEntry(japanese: "エアコンが壊れています", romaji: "eakon ga kowarete imasu", indonesian: "AC-nya rusak", english: "The air conditioner is broken", category: "Hotel"),
  PhraseEntry(japanese: "もうすこしください", romaji: "mou sukoshi kudasai", indonesian: "Tolong tambah sedikit", english: "A little more, please", category: "Restoran"),
  PhraseEntry(japanese: "辛くないものはありますか", romaji: "karakunai mono wa arimasu ka", indonesian: "Ada yang tidak pedas?", english: "Is there something not spicy?", category: "Restoran"),
  PhraseEntry(japanese: "お箸をください", romaji: "ohashi o kudasai", indonesian: "Tolong sumpit", english: "Chopsticks, please", category: "Restoran"),
  PhraseEntry(japanese: "右に曲がってください", romaji: "migi ni magatte kudasai", indonesian: "Belok kanan", english: "Turn right", category: "Tanya Arah"),
  PhraseEntry(japanese: "左に曲がってください", romaji: "hidari ni magatte kudasai", indonesian: "Belok kiri", english: "Turn left", category: "Tanya Arah"),
  PhraseEntry(japanese: "まっすぐ行ってください", romaji: "massugu itte kudasai", indonesian: "Jalan lurus", english: "Go straight", category: "Tanya Arah"),
  PhraseEntry(japanese: "近いですか", romaji: "chikai desu ka", indonesian: "Apakah dekat?", english: "Is it near?", category: "Tanya Arah"),
  PhraseEntry(japanese: "タクシーを呼んでください", romaji: "takushii o yonde kudasai", indonesian: "Tolong panggilkan taksi", english: "Please call a taxi", category: "Tanya Arah"),
  PhraseEntry(japanese: "安くしてください", romaji: "yasuku shite kudasai", indonesian: "Tolong lebih murah", english: "Please make it cheaper", category: "Belanja"),
  PhraseEntry(japanese: "これを見せてください", romaji: "kore o misete kudasai", indonesian: "Tolong tunjukkan yang ini", english: "Please show me this one", category: "Belanja"),
  PhraseEntry(japanese: "カードで払えますか", romaji: "kaado de haraemasu ka", indonesian: "Bisa bayar pakai kartu?", english: "Can I pay by card?", category: "Belanja"),
  PhraseEntry(japanese: "袋をください", romaji: "fukuro o kudasai", indonesian: "Tolong kantongnya", english: "A bag, please", category: "Belanja"),
  PhraseEntry(japanese: "買います", romaji: "kaimasu", indonesian: "Saya beli", english: "I’ll buy it", category: "Belanja"),
  PhraseEntry(japanese: "救急車を呼んでください", romaji: "kyuukyuusha o yonde kudasai", indonesian: "Tolong panggil ambulans", english: "Please call an ambulance", category: "Darurat"),
  PhraseEntry(japanese: "日本語がわかりません", romaji: "nihongo ga wakarimasen", indonesian: "Saya tidak mengerti bahasa Jepang", english: "I don’t understand Japanese", category: "Darurat"),
  PhraseEntry(japanese: "英語を話せますか", romaji: "eigo o hanasemasu ka", indonesian: "Bisakah Anda berbahasa Inggris?", english: "Can you speak English?", category: "Darurat"),
];
