import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/dictionary.dart';

/// Normalisasi romaji: huruf kecil + hilangkan makron (ō→o, dst).
String normR(String s) {
  return s
      .toLowerCase()
      .replaceAll('ā', 'a')
      .replaceAll('ī', 'i')
      .replaceAll('ū', 'u')
      .replaceAll('ē', 'e')
      .replaceAll('ō', 'o');
}

/// Bahasa yang didukung terjemah online.
enum TtsLang { ja, id, en }

extension TtsLangLabel on TtsLang {
  String get code => switch (this) {
        TtsLang.ja => 'ja',
        TtsLang.id => 'id',
        TtsLang.en => 'en',
      };

  String get label => switch (this) {
        TtsLang.ja => 'Jepang (日本語)',
        TtsLang.id => 'Indonesia',
        TtsLang.en => 'Inggris (English)',
      };
}

String entryText(DictEntry e, TtsLang lang) => switch (lang) {
      TtsLang.ja => e.japanese,
      TtsLang.id => e.indonesian,
      TtsLang.en => e.english,
    };

/// Cari di kamus (Jepang/kana/romaji/Indonesia/Inggris), maks 12 hasil.
List<DictEntry> searchDictionary(String query) {
  final q = query.trim();
  if (q.isEmpty) return [];
  final lq = q.toLowerCase();
  final nq = normR(q);
  return dictionary
      .where(
        (e) =>
            normR(e.japanese).contains(nq) ||
            normR(e.kana).contains(nq) ||
            normR(e.romaji).contains(nq) ||
            e.indonesian.toLowerCase().contains(lq) ||
            e.english.toLowerCase().contains(lq),
      )
      .take(12)
      .toList();
}

/// Cari entri yang cocok persis (dipakai fallback offline).
DictEntry? findEntry(String query) {
  final q = query.trim();
  if (q.isEmpty) return null;
  final nq = normR(q);
  final lq = q.toLowerCase();
  DictEntry? m;
  try {
    m = dictionary.firstWhere(
      (e) => normR(e.japanese) == nq || normR(e.kana) == nq,
    );
  } catch (_) {}
  m ??= () {
    try {
      return dictionary.firstWhere((e) => normR(e.romaji) == nq);
    } catch (_) {
      return null;
    }
  }();
  m ??= () {
    try {
      return dictionary.firstWhere(
        (e) =>
            e.indonesian.toLowerCase() == lq ||
            e.english.toLowerCase() == lq,
      );
    } catch (_) {
      return null;
    }
  }();
  m ??= () {
    try {
      return dictionary.firstWhere(
        (e) =>
            e.indonesian.toLowerCase().contains(lq) ||
            e.english.toLowerCase().contains(lq),
      );
    } catch (_) {
      return null;
    }
  }();
  return m;
}

/// Terjemah offline (fallback): pecah kalimat Jepang per kata kamus,
/// atau cari entri yang cocok untuk teks Indonesia/Inggris.
String? offlineTranslate(String text, TtsLang dst) {
  final t = text.trim();
  if (t.isEmpty) return null;
  final exact = findEntry(t);
  if (exact != null) return entryText(exact, dst);
  // Kalimat Jepang: segmentasi greedy dengan kata kamus terpanjang dulu.
  final keys = <String>{};
  for (final e in dictionary) {
    keys.add(e.japanese);
    keys.add(e.kana);
  }
  final sorted = keys.toList()..sort((a, b) => b.length.compareTo(a.length));
  final out = <String>[];
  var i = 0;
  var matchedAny = false;
  while (i < t.length) {
    String? hit;
    for (final k in sorted) {
      if (t.startsWith(k, i)) {
        hit = k;
        break;
      }
    }
    if (hit == null) {
      i++;
      continue;
    }
    final entry = dictionary.firstWhere(
      (e) => e.japanese == hit || e.kana == hit,
    );
    out.add(entryText(entry, dst));
    matchedAny = true;
    i += hit.length;
  }
  if (!matchedAny) return null;
  return out.join(' ');
}

/// Terjemah online via endpoint Google Translate tidak resmi (client=gtx).
/// Kembalikan null bila gagal (pemanggil memakai fallback offline).
Future<String?> translateOnline(
  String text,
  String src,
  TtsLang dst,
) async {
  final uri = Uri.parse(
    'https://translate.googleapis.com/translate_a/single'
    '?client=gtx&sl=$src&tl=${dst.code}&dt=t&q=${Uri.encodeComponent(text)}',
  );
  try {
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    if (data is! List || data.isEmpty) return null;
    final segments = data[0];
    if (segments is! List) return null;
    final buf = StringBuffer();
    for (final seg in segments) {
      if (seg is List && seg.isNotEmpty && seg[0] is String) {
        buf.write(seg[0] as String);
      }
    }
    final out = buf.toString().trim();
    return out.isEmpty ? null : out;
  } catch (_) {
    return null;
  }
}

/// Probe cepat: apakah endpoint translate bisa dijangkau.
Future<bool> probeOnline() async {
  try {
    final res = await http
        .get(
          Uri.parse(
            'https://translate.googleapis.com/translate_a/single'
            '?client=gtx&sl=auto&tl=id&dt=t&q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF',
          ),
        )
        .timeout(const Duration(seconds: 4));
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}
