// Ekstraksi data Fase 1 — Nihongo Santai (WebView HTML -> Dart).
// Membaca ~/workspace/translate-offline/app/index.html, mengevaluasi literal
// JS di dalamnya secara aman (bukan copy-paste manual), lalu menulis file Dart
// ke ~/workspace/nihongo-santai-flutter/lib/data/.
// Jalankan: node tools/extract-data.mjs
// Verifikasi: node tools/verify-data.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HOME = process.env.HOME;
const SRC = path.join(HOME, 'workspace/translate-offline/app/index.html');
const OUT = path.join(HOME, 'workspace/nihongo-santai-flutter/lib/data');
fs.mkdirSync(OUT, { recursive: true });

const html = fs.readFileSync(SRC, 'utf8');

// ---- Ambil literal JS dengan pencocokan kurung yang sadar-string ----
function extract(src, marker) {
  const i = src.indexOf(marker);
  if (i < 0) throw new Error('marker tidak ditemukan: ' + marker);
  let j = src.indexOf('[', i);
  let open = '['; let close = ']';
  const o2 = src.indexOf('{', i);
  if (o2 >= 0 && o2 < j) { j = o2; open = '{'; close = '}'; }
  let depth = 0, k = j, inStr = false, esc = false;
  for (; k < src.length; k++) {
    const ch = src[k];
    if (inStr) {
      if (esc) esc = false;
      else if (ch === '\\') esc = true;
      else if (ch === '"') inStr = false;
      continue;
    }
    if (ch === '"') { inStr = true; continue; }
    if (ch === open) depth++;
    else if (ch === close) { depth--; if (depth === 0) break; }
  }
  if (depth !== 0) throw new Error('kurung tidak seimbang untuk: ' + marker);
  return src.slice(j, k + 1);
}
const ev = (code, args = {}) =>
  new Function(...Object.keys(args), 'return (' + code + ')')(...Object.values(args));

// ---- Evaluasi dalam urutan dependensi (LESSONS memakai HIRA/KATA) ----
const HIRA = ev(extract(html, 'const HIRA='));
const HIRA_DAKU = ev(extract(html, 'const HIRA_DAKU='));
const KATA = ev(extract(html, 'const KATA='));
const KATA_DAKU = ev(extract(html, 'const KATA_DAKU='));
const DICT = ev(extract(html, 'const DICT ='));
const CATS = ev(extract(html, 'const CATS='));
const FRASA = ev(extract(html, 'const FRASA='));
const KONBINI = ev(extract(html, 'const KONBINI='));
const MENU = ev(extract(html, 'const MENU='));
const ALERGI = ev(extract(html, 'const ALERGI='));
const QUIZ = ev(extract(html, 'const QUIZ='));
const PACK = ev(extract(html, 'const PACK='));
const GRAMMAR = ev('{' + extract(html, 'const GRAMMAR=').slice(1, -1) + '}');
const LESSONS = ev(extract(html, 'const LESSONS='), { HIRA, HIRA_DAKU, KATA, KATA_DAKU });
const LEVELS = ev(extract(html, 'const LEVELS='));
const TPL = ev(extract(html, 'const TPL='));

// ---- Kota trip dari <select id="tripCity"> ----
const citySel = html.match(/<select id="tripCity">([\s\S]*?)<\/select>/);
if (!citySel) throw new Error('select tripCity tidak ditemukan');
const CITIES = [...citySel[1].matchAll(/<option value="([^"|]+)\|([^"]+)">/g)]
  .map((m) => ({ name: m[1], japanese: m[2] }));

// ---- Diet: 4 opsi dari <select id="dietSel"> + frasa Jepang dari showAlergiCard() ----
const dietSel = html.match(/<select id="dietSel">([\s\S]*?)<\/select>/);
if (!dietSel) throw new Error('select dietSel tidak ditemukan');
const dietPhrases = {};
for (const m of html.matchAll(/if\(diet==="(\w+)"\)\{ja\.push\("([^"]+)"\);tr\.push\("([^"]+)"\);\}/g)) {
  dietPhrases[m[1]] = { japanese: m[2], indonesian: m[3] };
}
const DIETS = [...dietSel[1].matchAll(/<option value="(\w+)">/g)]
  .map((m) => m[1])
  .filter((v) => v !== '')
  .map((v) => {
    const p = dietPhrases[v];
    if (!p) throw new Error('frasa diet tidak ditemukan untuk: ' + v);
    return { id: v, ...p };
  });

// ---- Helper Dart ----
const stripTags = (s) => s.replace(/<[^>]+>/g, '');
const dq = (s) => JSON.stringify(String(s)).replace(/\$/g, '\\$'); // string Dart "..." (escape $ anti-interpolasi)
const opt = (v) => (v === undefined || v === null ? 'null' : dq(v));
const strList = (arr) => arr === undefined ? 'null' : `[${arr.map(dq).join(', ')}]`;
const kanaList = (arr) =>
  arr === undefined ? 'null' : `[\n${arr.map(([k, r]) => `    KanaChar(${dq(k)}, ${dq(r)}),`).join('\n')}\n  ]`;

const header = (srcNote) =>
  `// Data diekstrak otomatis dari app/index.html (${srcNote}).\n// Jangan edit manual — jalankan ulang tools/extract-data.mjs bila sumber berubah.\n`;

function write(name, content) {
  fs.writeFileSync(path.join(OUT, name), content, 'utf8');
  console.log('ditulis:', name, `(${Buffer.byteLength(content, 'utf8')} byte)`);
}

// ================= dictionary.dart =================
write('dictionary.dart', `${header('DICT baris 485, CATS baris 976')}
/// Satu entri kamus Jepang–Indonesia–Inggris.
class DictEntry {
  const DictEntry({
    required this.japanese,
    required this.kana,
    required this.romaji,
    required this.indonesian,
    required this.english,
    required this.category,
  });

  /// Bentuk kanji/kana seperti di sumber (field \`j\`).
  final String japanese;

  /// Kana (field \`k\`).
  final String kana;

  /// Romaji (field \`r\`).
  final String romaji;

  /// Arti Bahasa Indonesia (field \`i\`).
  final String indonesian;

  /// Arti Bahasa Inggris (field \`e\`).
  final String english;

  /// Kunci kategori (field \`c\`), lihat [dictionaryCategories].
  final String category;
}

/// Nama kategori kamus (kunci -> label tampil).
const Map<String, String> dictionaryCategories = {
${Object.entries(CATS).map(([k, v]) => `  ${dq(k)}: ${dq(v)},`).join('\n')}
};

/// Kamus lengkap (${DICT.length} entri).
const List<DictEntry> dictionary = [
${DICT.map((d) => `  DictEntry(japanese: ${dq(d.j)}, kana: ${dq(d.k)}, romaji: ${dq(d.r)}, indonesian: ${dq(d.i)}, english: ${dq(d.e)}, category: ${dq(d.c)}),`).join('\n')}
];
`);

// ================= phrases.dart =================
write('phrases.dart', `${header('FRASA baris 979')}
/// Satu frasa perjalanan.
class PhraseEntry {
  const PhraseEntry({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
    this.english,
    required this.category,
  });

  /// Kalimat Jepang (field \`ja\`).
  final String japanese;

  /// Romaji (field \`rm\`).
  final String romaji;

  /// Arti Bahasa Indonesia (field \`id\`).
  final String indonesian;

  /// Arti Bahasa Inggris (field \`en\`); null bila tidak ada di sumber.
  final String? english;

  /// Kategori frasa (field \`c\`).
  final String category;
}

/// Frasa perjalanan (${FRASA.length} entri).
const List<PhraseEntry> phrases = [
${FRASA.map((f) => `  PhraseEntry(japanese: ${dq(f.ja)}, romaji: ${dq(f.rm)}, indonesian: ${dq(f.id)}, english: ${opt(f.en)}, category: ${dq(f.c)}),`).join('\n')}
];
`);

// ================= konbini.dart =================
write('konbini.dart', `${header('KONBINI baris 1048')}
/// Satu item konbini.
class KonbiniItem {
  const KonbiniItem({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
    required this.category,
  });

  /// Nama Jepang (field \`ja\`).
  final String japanese;

  /// Romaji (field \`rm\`).
  final String romaji;

  /// Arti Bahasa Indonesia (field \`id\`).
  final String indonesian;

  /// Kategori (field \`c\`).
  final String category;
}

/// Daftar konbini (${KONBINI.length} item).
const List<KonbiniItem> konbiniItems = [
${KONBINI.map((k) => `  KonbiniItem(japanese: ${dq(k.ja)}, romaji: ${dq(k.rm)}, indonesian: ${dq(k.id)}, category: ${dq(k.c)}),`).join('\n')}
];
`);

// ================= menu.dart =================
write('menu.dart', `${header('MENU baris 1083, ALERGI baris 1126, diet dari select #dietSel + showAlergiCard()')}
/// Satu kata menu restoran (decoder menu).
class MenuItem {
  const MenuItem({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
    required this.category,
  });

  /// Kata Jepang (field \`ja\`).
  final String japanese;

  /// Romaji (field \`rm\`).
  final String romaji;

  /// Arti Bahasa Indonesia (field \`id\`).
  final String indonesian;

  /// Kategori (field \`c\`).
  final String category;
}

/// Satu alergen untuk kartu alergi.
class AllergyItem {
  const AllergyItem({
    required this.japanese,
    required this.romaji,
    required this.indonesian,
  });

  /// Nama alergen Jepang (field \`ja\`).
  final String japanese;

  /// Romaji (field \`rm\`).
  final String romaji;

  /// Arti Bahasa Indonesia (field \`id\`).
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

/// Kata menu (${MENU.length} kata).
const List<MenuItem> menuItems = [
${MENU.map((m) => `  MenuItem(japanese: ${dq(m.ja)}, romaji: ${dq(m.rm)}, indonesian: ${dq(m.id)}, category: ${dq(m.c)}),`).join('\n')}
];

/// Daftar alergen (${ALERGI.length} entri).
const List<AllergyItem> allergyItems = [
${ALERGI.map((a) => `  AllergyItem(japanese: ${dq(a.ja)}, romaji: ${dq(a.rm)}, indonesian: ${dq(a.id)}),`).join('\n')}
];

/// Pilihan diet (${DIETS.length} opsi; opsi kosong "Tidak ada" tidak disertakan).
const List<DietOption> dietOptions = [
${DIETS.map((d) => `  DietOption(id: ${dq(d.id)}, japanese: ${dq(d.japanese)}, indonesian: ${dq(d.indonesian)}),`).join('\n')}
];
`);

// ================= quiz.dart =================
write('quiz.dart', `${header('QUIZ baris 1134')}
/// Satu soal kuis travel N5.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  /// Pertanyaan (field \`q\`).
  final String question;

  /// Pilihan jawaban (field \`o\`).
  final List<String> options;

  /// Indeks jawaban benar (field \`a\`).
  final int answerIndex;
}

/// Kuis travel N5 (${QUIZ.length} soal).
const List<QuizQuestion> travelQuiz = [
${QUIZ.map((q) => `  QuizQuestion(question: ${dq(q.q)}, options: ${strList(q.o)}, answerIndex: ${q.a}),`).join('\n')}
];
`);

// ================= kana.dart =================
const kanaPairs = (arr) => arr.map(([k, r]) => `  KanaChar(${dq(k)}, ${dq(r)}),`).join('\n');
write('kana.dart', `${header('HIRA/HIRA_DAKU/KATA/KATA_DAKU baris 1154-1157')}
/// Satu huruf kana beserta romajinya.
class KanaChar {
  const KanaChar(this.kana, this.romaji);

  /// Huruf kana.
  final String kana;

  /// Romaji.
  final String romaji;
}

/// Hiragana dasar (${HIRA.length} huruf).
const List<KanaChar> hiragana = [
${kanaPairs(HIRA)}
];

/// Hiragana dakuten/handakuten (${HIRA_DAKU.length} huruf).
const List<KanaChar> hiraganaDakuten = [
${kanaPairs(HIRA_DAKU)}
];

/// Katakana dasar (${KATA.length} huruf).
const List<KanaChar> katakana = [
${kanaPairs(KATA)}
];

/// Katakana dakuten/handakuten (${KATA_DAKU.length} huruf).
const List<KanaChar> katakanaDakuten = [
${kanaPairs(KATA_DAKU)}
];
`);

// ================= grammar.dart =================
const grammarKeys = Object.keys(GRAMMAR).sort((a, b) => +a.slice(1) - +b.slice(1));
const grammarTotal = grammarKeys.reduce((n, k) => n + GRAMMAR[k].length, 0);
write('grammar.dart', `${header('GRAMMAR baris 1159: 24 grup x 10 soal')}
/// Satu soal tata bahasa.
/// Jenis soal (field \`t\`):
/// - \`mc\`: pilihan ganda, pakai [question], [options], [answerIndex].
/// - \`fill\`: isi titik-titik, pakai [sentence], [options], [answerIndex].
/// - \`arrange\`: susun kata, pakai [words]; tanpa [options]/[answerIndex].
class GrammarQuestion {
  const GrammarQuestion({
    required this.type,
    this.question,
    this.sentence,
    this.options,
    this.words,
    this.answerIndex,
    this.note,
  });

  /// Jenis soal: 'mc' | 'fill' | 'arrange'.
  final String type;

  /// Pertanyaan (field \`q\`, hanya mc).
  final String? question;

  /// Kalimat rumpang (field \`s\`, hanya fill).
  final String? sentence;

  /// Pilihan jawaban (field \`o\`, mc & fill).
  final List<String>? options;

  /// Kata-kata untuk disusun (field \`w\`, hanya arrange).
  final List<String>? words;

  /// Indeks jawaban benar (field \`a\`, mc & fill).
  final int? answerIndex;

  /// Penjelasan (field \`note\`).
  final String? note;
}

/// Soal tata bahasa per grup (${grammarKeys.length} grup, ${grammarTotal} soal).
/// Kunci grup (g1..g24) sama dengan [Lesson.grammarId] di lessons.dart.
const Map<String, List<GrammarQuestion>> grammarQuestions = {
${grammarKeys.map((g) => `  ${dq(g)}: [\n${GRAMMAR[g].map((q) => `    GrammarQuestion(type: ${dq(q.t)}, question: ${opt(q.q)}, sentence: ${opt(q.s)}, options: ${strList(q.o)}, words: ${strList(q.w)}, answerIndex: ${q.a === undefined ? 'null' : q.a}, note: ${opt(q.note)}),`).join('\n')}\n  ],`).join('\n')}
};
`);

// ================= lessons.dart =================
write('lessons.dart', `${header('LESSONS baris 1427, LEVELS baris 1479')}
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

  /// Level: N5 | N4 | N3 | N2 | N1 (field \`lvl\`).
  final String level;

  /// ID pelajaran (field \`id\`).
  final String id;

  /// Jalur/track pelajaran (field \`track\`).
  final String track;

  /// Ikon (huruf kana atau emoji, field \`icon\`).
  final String icon;

  /// Judul (field \`title\`).
  final String title;

  /// Deskripsi (field \`desc\`).
  final String description;

  /// Jenis: 'kana' | 'vocab' | 'grammar' (field \`kind\`).
  final String kind;

  /// Skrip kana: 'h' = hiragana, 'k' = katakana (field \`script\`, hanya kind kana).
  final String? script;

  /// Huruf kana pelajaran ini (field \`set\`, hanya kind kana).
  /// Di sumber berupa potongan HIRA/KATA — sudah di-resolve jadi huruf nyata.
  final List<KanaChar>? kanaSet;

  /// Kunci kategori kamus (field \`cats\`, hanya kind vocab).
  final List<String>? categories;

  /// ID grup soal tata bahasa (field \`gid\`, hanya kind grammar).
  final String? grammarId;

  /// Pengantar materi (field \`intro\`, hanya kind grammar).
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

  /// ID level (field \`id\`).
  final String id;

  /// Nama tampil (field \`name\`).
  final String name;

  /// Deskripsi (field \`desc\`).
  final String description;

  /// Ikon (field \`icon\`).
  final String icon;
}

/// Daftar level (${LEVELS.length} level).
const List<LevelInfo> levels = [
${LEVELS.map((l) => `  LevelInfo(id: ${dq(l.id)}, name: ${dq(l.name)}, description: ${dq(l.desc)}, icon: ${dq(l.icon)}),`).join('\n')}
];

/// Daftar pelajaran (${LESSONS.length} pelajaran).
const List<Lesson> lessons = [
${LESSONS.map((l) => `  Lesson(level: ${dq(l.lvl)}, id: ${dq(l.id)}, track: ${dq(l.track)}, icon: ${dq(l.icon)}, title: ${dq(l.title)}, description: ${dq(l.desc)}, kind: ${dq(l.kind)}, script: ${opt(l.script)}, kanaSet: ${kanaList(l.set)}, categories: ${strList(l.cats)}, grammarId: ${opt(l.gid)}, intro: ${opt(l.intro === undefined ? undefined : stripTags(l.intro))}),`).join('\n')}
];
`);

// ================= trip.dart =================
write('trip.dart', `${header('kota dari <option> tripCity ~baris 374; TPL baris 1909; PACK baris 1146')}
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

  /// Hari ke- (field \`d\`).
  final int day;

  /// Jam (field \`t\`, format HH:MM).
  final String time;

  /// Kegiatan (field \`x\`).
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

  /// Nama barang Jepang (field \`ja\`).
  final String japanese;

  /// Romaji (field \`rm\`).
  final String romaji;

  /// Arti Bahasa Indonesia (field \`id\`).
  final String indonesian;
}

/// Kota tujuan (${CITIES.length} kota).
const List<TripCity> tripCities = [
${CITIES.map((c) => `  TripCity(name: ${dq(c.name)}, japanese: ${dq(c.japanese)}),`).join('\n')}
];

/// Template itinerary per kota (${Object.keys(TPL).length} kota).
const List<TripTemplate> tripTemplates = [
${Object.entries(TPL).map(([key, v]) => {
  const [name, japanese] = key.split('|');
  return `  TripTemplate(cityName: ${dq(name)}, cityJapanese: ${dq(japanese)}, items: [\n${v.items.map((it) => `    ItineraryItem(day: ${it.d}, time: ${dq(it.t)}, activity: ${dq(it.x)}),`).join('\n')}\n  ]),`;
}).join('\n')}
];

/// Checklist packing (${PACK.length} item).
const List<PackItem> packingList = [
${PACK.map((p) => `  PackItem(japanese: ${dq(p.ja)}, romaji: ${dq(p.rm)}, indonesian: ${dq(p.id)}),`).join('\n')}
];
`);

// ---- Ringkasan hitungan sumber (untuk verifikasi) ----
const summary = {
  dictionary: DICT.length,
  phrases: FRASA.length,
  konbini: KONBINI.length,
  menu: MENU.length,
  allergy: ALERGI.length,
  diet: DIETS.length,
  quiz: QUIZ.length,
  hiragana: HIRA.length,
  hiraganaDakuten: HIRA_DAKU.length,
  katakana: KATA.length,
  katakanaDakuten: KATA_DAKU.length,
  grammarGroups: grammarKeys.length,
  grammarQuestions: grammarTotal,
  lessons: LESSONS.length,
  lessonsPerLevel: Object.fromEntries(['N5', 'N4', 'N3', 'N2', 'N1'].map((l) => [l, LESSONS.filter((x) => x.lvl === l).length])),
  levels: LEVELS.length,
  cities: CITIES.length,
  templates: Object.keys(TPL).length,
  templateItems: Object.fromEntries(Object.entries(TPL).map(([k, v]) => [k, v.items.length])),
  packing: PACK.length,
};
fs.writeFileSync(path.join(HOME, 'workspace/nihongo-santai-flutter/tools/extract-summary.json'), JSON.stringify(summary, null, 2));
console.log('\nRingkasan sumber:', JSON.stringify(summary));
console.log('Selesai. Jalankan node tools/verify-data.mjs untuk verifikasi.');
