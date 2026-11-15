// Verifikasi hasil ekstraksi Fase 1 — menghitung dari file Dart yang dihasilkan
// dan membandingkannya dengan angka target (dari sumber HTML).
// Jalankan: node tools/verify-data.mjs
import fs from 'node:fs';
import path from 'node:path';

const HOME = process.env.HOME;
const DIR = path.join(HOME, 'workspace/nihongo-santai-flutter/lib/data');
const read = (f) => fs.readFileSync(path.join(DIR, f), 'utf8');
const count = (text, re) => (text.match(re) || []).length;

const TARGETS = [
  { group: 'Kamus (dictionary)', file: 'dictionary.dart', got: () => count(read('dictionary.dart'), /^  DictEntry\(/gm), want: 489 },
  { group: 'Kategori kamus', file: 'dictionary.dart', got: () => count(read('dictionary.dart').split('dictionaryCategories = {')[1].split('};')[0], /: "/g), want: 18 },
  { group: 'Frasa', file: 'phrases.dart', got: () => count(read('phrases.dart'), /^  PhraseEntry\(/gm), want: 67 },
  { group: 'Konbini', file: 'konbini.dart', got: () => count(read('konbini.dart'), /^  KonbiniItem\(/gm), want: 33 },
  { group: 'Menu', file: 'menu.dart', got: () => count(read('menu.dart'), /^  MenuItem\(/gm), want: 41 },
  { group: 'Alergi', file: 'menu.dart', got: () => count(read('menu.dart'), /^  AllergyItem\(/gm), want: 12 },
  { group: 'Diet', file: 'menu.dart', got: () => count(read('menu.dart'), /^  DietOption\(/gm), want: 4 },
  { group: 'Kuis travel (soal)', file: 'quiz.dart', got: () => count(read('quiz.dart'), /^  QuizQuestion\(/gm), want: 10 },
  { group: 'Hiragana', file: 'kana.dart', got: () => count(read('kana.dart').split('hiraganaDakuten')[0], /^  KanaChar\(/gm), want: 46 },
  { group: 'Hiragana dakuten', file: 'kana.dart', got: () => count(read('kana.dart').split('hiraganaDakuten = [')[1].split('];')[0], /^  KanaChar\(/gm), want: 25 },
  { group: 'Katakana', file: 'kana.dart', got: () => count(read('kana.dart').split('katakana = [')[1].split('];')[0], /^  KanaChar\(/gm), want: 46 },
  { group: 'Katakana dakuten', file: 'kana.dart', got: () => count(read('kana.dart').split('katakanaDakuten = [')[1].split('];')[0], /^  KanaChar\(/gm), want: 25 },
  { group: 'Grup grammar', file: 'grammar.dart', got: () => count(read('grammar.dart'), /^  "g\d+": \[/gm), want: 24 },
  { group: 'Soal grammar (total)', file: 'grammar.dart', got: () => count(read('grammar.dart'), /^    GrammarQuestion\(/gm), want: 240 },
  { group: 'Lessons', file: 'lessons.dart', got: () => count(read('lessons.dart'), /^  Lesson\(/gm), want: 48 },
  { group: 'Lessons N5', file: 'lessons.dart', got: () => count(read('lessons.dart'), /level: "N5"/g), want: 19 },
  { group: 'Lessons N4', file: 'lessons.dart', got: () => count(read('lessons.dart'), /level: "N4"/g), want: 10 },
  { group: 'Lessons N3', file: 'lessons.dart', got: () => count(read('lessons.dart'), /level: "N3"/g), want: 8 },
  { group: 'Lessons N2', file: 'lessons.dart', got: () => count(read('lessons.dart'), /level: "N2"/g), want: 6 },
  { group: 'Lessons N1', file: 'lessons.dart', got: () => count(read('lessons.dart'), /level: "N1"/g), want: 5 },
  { group: 'Levels', file: 'lessons.dart', got: () => count(read('lessons.dart'), /^  LevelInfo\(/gm), want: 5 },
  { group: 'Kota trip', file: 'trip.dart', got: () => count(read('trip.dart'), /^  TripCity\(/gm), want: 8 },
  { group: 'Template itinerary (kota)', file: 'trip.dart', got: () => count(read('trip.dart'), /^  TripTemplate\(/gm), want: 8 },
  { group: 'Packing', file: 'trip.dart', got: () => count(read('trip.dart'), /^  PackItem\(/gm), want: 10 },
];

// Template per kota (jumlah item itinerary per kota)
const tplWant = { Tokyo: 12, Kyoto: 12, Osaka: 8, Nara: 7, 'Fuji / Kawaguchiko': 7, Hiroshima: 8, Hokkaido: 12, Okinawa: 12 };
const trip = read('trip.dart');
for (const [city, want] of Object.entries(tplWant)) {
  TARGETS.push({
    group: `Template ${city} (item)`, file: 'trip.dart',
    got: () => {
      const block = trip.split(`cityName: "${city}"`)[1].split('TripTemplate(')[0];
      return count(block, /^    ItineraryItem\(/gm);
    },
    want,
  });
}

let fail = 0;
console.log('Kelompok | File | Hasil | Target | Status');
console.log('---|---|---|---|---');
for (const t of TARGETS) {
  let got;
  try { got = t.got(); } catch (e) { got = 'ERROR: ' + e.message; }
  const ok = got === t.want;
  if (!ok) fail++;
  console.log(`${t.group} | ${t.file} | ${got} | ${t.want} | ${ok ? 'COCOK' : '**TIDAK COCOK**'}`);
}

// ---- Pemeriksaan sisa sintaks JS / kotoran ----
console.log('\nPemeriksaan kebersihan sintaks:');
const stripComments = (t) => t.split('\n').filter((l) => !/^\s*\/\//.test(l)).join('\n');
const allDart = ['dictionary.dart', 'phrases.dart', 'konbini.dart', 'menu.dart', 'quiz.dart', 'kana.dart', 'grammar.dart', 'lessons.dart', 'trip.dart']
  .map((f) => ({ f, t: read(f), code: stripComments(read(f)) }));
const forbidden = [
  [/\.slice\(/, 'ekspresi .slice('],
  [/\bundefined\b/, 'kata undefined'],
  [/`/, 'backtick JS'],
  [/\bconst (DICT|FRASA|KONBINI|MENU|ALERGI|QUIZ|PACK|HIRA|KATA|GRAMMAR|LESSONS|LEVELS|TPL)\b/, 'nama const JS asli'],
  [/=>/, 'arrow function JS'],
  [/<b>|<\/b>|<i>|&amp;|&lt;|&gt;/, 'tag HTML / entitas HTML'],
  [/\$\{/, 'interpolasi ${'],
];
for (const [re, label] of forbidden) {
  const hits = allDart.filter(({ code }) => re.test(code)).map(({ f }) => f);
  console.log(`- ${label}: ${hits.length ? '**DITEMUKAN di ' + hits.join(', ') + '**' : 'bersih'}`);
  if (hits.length) fail++;
}
let braceFail = 0;
for (const { f, t } of allDart) {
  const open = (t.match(/{/g) || []).length, close = (t.match(/}/g) || []).length;
  const openB = (t.match(/\[/g) || []).length, closeB = (t.match(/\]/g) || []).length;
  if (open !== close || openB !== closeB) { console.log(`- ${f}: kurung TIDAK seimbang { ${open}/${close} [ ${openB}/${closeB}`); braceFail++; }
}
if (braceFail) fail += braceFail;
console.log('- Kurung {} dan [] seimbang di semua file: ' + (braceFail === 0 ? 'ya' : '**TIDAK**'));

// ---- Uji silang isi (spot check terhadap HTML sumber) ----
console.log('\nUji silang isi (harus ada di file Dart DAN di HTML sumber):');
const html = fs.readFileSync(path.join(HOME, 'workspace/translate-offline/app/index.html'), 'utf8');
const spots = [
  ['dictionary.dart', 'こんにちは', 'konnichiwa'],
  ['phrases.dart', 'トイレはどこですか', 'Tanya Arah'],
  ['konbini.dart', 'おにぎり', 'Nasi kepal'],
  ['menu.dart', 'ベジタリアンです。', 'nopork'],
  ['quiz.dart', '「トイレはどこですか。」 artinya apa?', 'Minta bon / tagihan'],
  ['kana.dart', 'ん', 'ぢ'],
  ['grammar.dart', 'わたしは ダニエルです', '余儀なくされる” artinya?'],
  ['lessons.dart', 'Hiragana 1 — あ行・か行', 'Tata bahasa N1 — 3: ~wo kawakiri ni'],
  ['trip.dart', 'Kuil Kiyomizu-dera', 'Akuarium Churaumi'],
];
for (const [f, ...needles] of spots) {
  const t = read(f);
  const missing = needles.filter((n) => !t.includes(n) || !html.includes(n));
  console.log(`- ${f}: ${missing.length ? '**HILANG: ' + missing.join(' | ') + '**' : 'semua spot check ada'}`);
  if (missing.length) fail++;
}
// Intro lessons bebas tag HTML
const lessons = read('lessons.dart');
console.log('- Intro lessons bebas <b>: ' + (!/<b>/.test(lessons) ? 'ya' : '**TIDAK**'));

console.log(fail === 0 ? '\nVERIFIKASI LULUS: semua target cocok, tidak ada sisa JS.' : `\nVERIFIKASI GAGAL: ${fail} masalah.`);
process.exit(fail === 0 ? 0 : 1);
