import 'dart:math';

import 'package:flutter/material.dart';

import '../data/dictionary.dart';
import '../data/grammar.dart';
import '../data/kanji.dart';
import '../data/lessons.dart';
import '../data/quiz.dart';
import '../services/store.dart';
import '../widgets.dart';
import 'flashcard_screen.dart';
import 'quiz_view.dart';

/// Layar Materi ala Goukaku: level N5, tab Kosakata / Kanji / Bunpou,
/// BAB, kartu flashcard & latihan per BAB, dan detail kanji
/// (bushu, komponen, cara mengingat, kanji mirip, contoh kosakata).
class MateriScreen extends StatefulWidget {
  const MateriScreen({super.key, required this.state, required this.onBack});

  final AppState state;
  final VoidCallback onBack;

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  int _tab = 1; // 0 Kosakata | 1 Kanji | 2 Bunpou
  int _bab = 1;

  static const int _kosakataPerBab = 28;
  static const Color _slate = Color(0xFF3D5A73);
  static const Color _cream = Color(0xFFFFFBF2);

  int get _kosakataBabCount => (dictionary.length / _kosakataPerBab).ceil();

  List<DictEntry> _kosakataBab(int bab) {
    final start = (bab - 1) * _kosakataPerBab;
    final end = (start + _kosakataPerBab).clamp(0, dictionary.length);
    if (start >= dictionary.length) return [];
    return dictionary.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _levelChips(),
            _tabs(),
            if (_tab != 2) _babSelector(),
            Expanded(child: _content()),
          ],
        );
      },
    );
  }

  // ---------------- Header & navigasi ----------------

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Text('Materi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/belajar-hero.png',
              height: 56,
              width: 120,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelChips() {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final lv in levels)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(lv),
                selected: lv == 'N5',
                selectedColor: _slate,
                labelStyle: TextStyle(
                  color: lv == 'N5' ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) {
                  if (lv != 'N5') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Level $lv segera hadir — saat ini baru N5')),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabs() {
    const labels = ['Kosakata', 'Kanji', 'Bunpou'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => setState(() {
                    _tab = i;
                    _bab = 1;
                  }),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          _tab == i ? _slate : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _tab == i ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _babSelector() {
    final count = _tab == 0 ? _kosakataBabCount : kanjiBabs.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      child: Row(
        children: [
          const Text('BAB',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: count,
                itemBuilder: (context, i) {
                  final n = i + 1;
                  final active = _bab == n;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _bab = n),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? _slate : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: active
                                  ? _slate
                                  : Colors.grey.shade300),
                        ),
                        child: Text('$n',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: active
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Konten per tab ----------------

  Widget _content() {
    if (_tab == 2) return _bunpouList();
    if (_tab == 1) return _kanjiContent();
    return _kosakataContent();
  }

  /// Kartu BAB ala Goukaku: judul, jumlah kartu, progres hafal, 2 tombol.
  Widget _babCard({
    required String title,
    required int total,
    required int hafal,
    required VoidCallback onFlashcard,
    required VoidCallback onLatihan,
  }) {
    final progress = total == 0 ? 0.0 : hafal / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _slate,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('$total kartu',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 6),
                  Text('$hafal hafal',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                ElevatedButton(
                  onPressed: onFlashcard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _slate,
                  ),
                  child: const Text('Mulai Flashcard'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onLatihan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Mulai Latihan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Tab Kanji ----------------

  Widget _kanjiContent() {
    final cards = kanjiByBab(_bab);
    final babInfo = kanjiBabs.firstWhere((b) => b.nomor == _bab);
    final hafal =
        cards.where((k) => widget.state.isKanjiHafal(k.kanji)).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _babCard(
          title: 'BAB $_bab',
          total: cards.length,
          hafal: hafal,
          onFlashcard: () => _openKanjiFlashcard(cards),
          onLatihan: () => _openKanjiQuiz(cards),
        ),
        if (babInfo.bushu != null) _bushuIntroCard(babInfo.bushu!),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemCount: cards.length,
            itemBuilder: (context, i) => _kanjiGridCard(cards[i]),
          ),
        ),
      ],
    );
  }

  Widget _bushuIntroCard(String bushu) {
    KanjiComponent? comp;
    for (final k in kanjiCards) {
      for (final c in k.components) {
        if (c.kanji == bushu) {
          comp = c;
          break;
        }
      }
      if (comp != null) break;
    }
    if (comp == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _slate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(bushu,
                    style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BUSYU 部首',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          letterSpacing: 1)),
                  Text('${comp.reading} (${comp.arti})',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(comp.theme,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kanjiGridCard(KanjiCard k) {
    final hafal = widget.state.isKanjiHafal(k.kanji);
    return InkWell(
      onTap: () => _showKanjiDetail(k),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => widget.state.toggleKanjiHafal(k.kanji),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hafal
                          ? const Color(0xFF15803D)
                          : Colors.transparent,
                      border: Border.all(
                          color: hafal
                              ? const Color(0xFF15803D)
                              : Colors.grey.shade400),
                    ),
                    child: hafal
                        ? const Icon(Icons.check,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const Spacer(),
                Text('BAB ${k.bab}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 6),
            _readingLine('ON', k.on),
            if (k.kun.isNotEmpty) _readingLine('KUN', k.kun),
            const SizedBox(height: 2),
            Text(k.kanji,
                style:
                    const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
            Text(k.arti,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _miniBtn('部', () => _showKanjiDetail(k, section: 'bushu')),
                _miniBtn('例', () => _showKanjiDetail(k, section: 'contoh')),
                _miniBtn('似', () => _showKanjiDetail(k, section: 'mirip')),
                _miniBtn('書', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Urutan goresan (書き方) segera hadir')),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _readingLine(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _slate,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _miniBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _openKanjiFlashcard(List<KanjiCard> cards) {
    final items = cards
        .map((k) => FlashcardItem(
              kanjiOrKana: k.kanji,
              romaji:
                  'ON ${k.on}${k.kun.isNotEmpty ? ' ・ KUN ${k.kun}' : ''}',
              arti: k.arti,
            ))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          kategori: 'Kanji BAB $_bab',
          customCards: items,
        ),
      ),
    );
  }

  void _openKanjiQuiz(List<KanjiCard> cards) {
    final rnd = Random();
    final qs = cards.map((k) {
      final others = cards
          .where((x) => x.kanji != k.kanji)
          .map((x) => x.arti)
          .toList()
        ..shuffle(rnd);
      final opts = [k.arti, ...others.take(3)]..shuffle(rnd);
      return QuizQuestion(
        question: '「${k.kanji}」 artinya apa?',
        options: opts,
        answerIndex: opts.indexOf(k.arti),
      );
    }).toList()
      ..shuffle(rnd);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizView(
          state: widget.state,
          onBack: () => Navigator.pop(context),
          title: 'Latihan Kanji BAB $_bab',
          questions: qs,
          saveBest: false,
        ),
      ),
    );
  }

  // ---------------- Tab Kosakata ----------------

  Widget _kosakataContent() {
    final words = _kosakataBab(_bab);
    final hafal =
        words.where((w) => widget.state.isKosakataHafal(w.japanese)).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _babCard(
          title: 'BAB $_bab',
          total: words.length,
          hafal: hafal,
          onFlashcard: () => _openKosakataFlashcard(words),
          onLatihan: () => _openKosakataQuiz(words),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Text('Ketuk kartu untuk menandai hafal.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: words.length,
            itemBuilder: (context, i) => _kosakataGridCard(words[i]),
          ),
        ),
      ],
    );
  }

  Widget _kosakataGridCard(DictEntry w) {
    final hafal = widget.state.isKosakataHafal(w.japanese);
    return InkWell(
      onTap: () => widget.state.toggleKosakataHafal(w.japanese),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hafal
                        ? const Color(0xFF15803D)
                        : Colors.transparent,
                    border: Border.all(
                        color: hafal
                            ? const Color(0xFF15803D)
                            : Colors.grey.shade400),
                  ),
                  child: hafal
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const Spacer(),
                Text(hafal ? 'Hafal' : 'Belum hafal',
                    style: TextStyle(
                        fontSize: 11,
                        color: hafal
                            ? const Color(0xFF15803D)
                            : Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 6),
            Text(w.kana,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFB91C1C))),
            Text(w.japanese,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            Text(w.romaji,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(w.indonesian,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _openKosakataFlashcard(List<DictEntry> words) {
    final items = words
        .map((w) => FlashcardItem(
              kanjiOrKana: w.japanese,
              romaji: w.romaji,
              arti: w.indonesian,
            ))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          kategori: 'Kosakata BAB $_bab',
          customCards: items,
        ),
      ),
    );
  }

  void _openKosakataQuiz(List<DictEntry> words) {
    final rnd = Random();
    final qs = words.map((w) {
      final others = words
          .where((x) => x.japanese != w.japanese)
          .map((x) => x.indonesian)
          .toList()
        ..shuffle(rnd);
      final opts = [w.indonesian, ...others.take(3)]..shuffle(rnd);
      return QuizQuestion(
        question: '「${w.japanese}」 artinya apa?',
        options: opts,
        answerIndex: opts.indexOf(w.indonesian),
      );
    }).toList()
      ..shuffle(rnd);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizView(
          state: widget.state,
          onBack: () => Navigator.pop(context),
          title: 'Latihan Kosakata BAB $_bab',
          questions: qs,
          saveBest: false,
        ),
      ),
    );
  }

  // ---------------- Tab Bunpou ----------------

  Lesson? _lessonForGroup(String gid) {
    for (final l in lessons) {
      if (l.grammarId == gid) return l;
    }
    return null;
  }

  Widget _bunpouList() {
    final groups = grammarQuestions.keys.toList()
      ..sort((a, b) =>
          int.parse(a.substring(1)).compareTo(int.parse(b.substring(1))));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final gid = groups[i];
        final lesson = _lessonForGroup(gid);
        final qs = grammarQuestions[gid] ?? [];
        final mcCount = qs
            .where((q) =>
                (q.type == 'mc' || q.type == 'fill') &&
                q.options != null &&
                q.answerIndex != null)
            .length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => _openBunpouQuiz(gid, lesson?.title ?? 'Bunpou $gid'),
            child: Row(
              children: [
                const Text('📝', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          lesson?.title ?? 'Bunpou ${gid.toUpperCase()}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(
                          lesson?.description ??
                              '$mcCount soal pilihan ganda',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openBunpouQuiz(String gid, String title) {
    final rnd = Random();
    final pool = <QuizQuestion>[];
    for (final g in grammarQuestions[gid] ?? []) {
      if ((g.type == 'mc' || g.type == 'fill') &&
          g.options != null &&
          g.answerIndex != null) {
        pool.add(QuizQuestion(
          question: g.type == 'mc' ? (g.question ?? '') : (g.sentence ?? ''),
          options: g.options!,
          answerIndex: g.answerIndex!,
        ));
      }
    }
    pool.shuffle(rnd);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizView(
          state: widget.state,
          onBack: () => Navigator.pop(context),
          title: title,
          questions: pool.take(10).toList(),
          saveBest: false,
        ),
      ),
    );
  }

  // ---------------- Detail kanji (bottom sheet) ----------------

  void _showKanjiDetail(KanjiCard k, {String section = 'atas'}) {
    final keyAtas = GlobalKey();
    final keyBushu = GlobalKey();
    final keyContoh = GlobalKey();
    final keyMirip = GlobalKey();

    void scrollTo(GlobalKey key) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 300));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  final hafal = widget.state.isKanjiHafal(k.kanji);
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // --- Kepala: kanji + bacaan + arti ---
                        Container(
                          key: keyAtas,
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(k.kanji,
                                  style: const TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("ON'YOMI",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                          letterSpacing: 1)),
                                  const SizedBox(width: 6),
                                  Text(k.on,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 16),
                                  Text("KUN'YOMI",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                          letterSpacing: 1)),
                                  const SizedBox(width: 6),
                                  Text(k.kun.isEmpty ? '–' : k.kun,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: k.arti
                                    .split(',')
                                    .map((a) => Chip(
                                          label: Text(a.trim()),
                                          backgroundColor: Colors.white,
                                          visualDensity:
                                              VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // --- Tombol lompat bagian ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _sheetPill('部 Komponen',
                                () => scrollTo(keyBushu)),
                            const SizedBox(width: 8),
                            _sheetPill('例 Kosakata',
                                () => scrollTo(keyContoh)),
                            const SizedBox(width: 8),
                            _sheetPill(
                                '似 Mirip', () => scrollTo(keyMirip)),
                            const SizedBox(width: 8),
                            _sheetPill('書き方', () {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Urutan goresan (書き方) segera hadir')),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // --- Tandai hafal ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.state.toggleKanjiHafal(k.kanji);
                              setSheetState(() {});
                            },
                            icon: Icon(
                                hafal ? Icons.check_circle : Icons.circle_outlined),
                            label: Text(hafal
                                ? 'Sudah hafal ✓ — ketuk untuk batalkan'
                                : 'Tandai hafal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hafal
                                  ? const Color(0xFF15803D)
                                  : _slate,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --- Komponen ---
                        Container(key: keyBushu),
                        Text('BUSYU & KOMPONEN',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1)),
                        const SizedBox(height: 8),
                        for (final c in k.components) ...[
                          _componentCard(c, k.kanji),
                          const SizedBox(height: 10),
                        ],
                        // --- Ilustrasi / cara mengingat ---
                        _infoBox(
                          title: '💡 CARA MENGINGAT',
                          body: k.mnemonic,
                        ),
                        const SizedBox(height: 10),
                        // --- Kanji mirip ---
                        if (k.similar != null) ...[
                          Container(key: keyMirip),
                          _infoBox(
                            title: 'KANJI MIRIP',
                            body:
                                'Jangan tertukar dengan 「${k.similar}」 — ${k.similarDiff ?? ''}',
                            highlight: true,
                          ),
                          const SizedBox(height: 10),
                        ],
                        // --- Contoh kosakata ---
                        Container(key: keyContoh),
                        Text('CONTOH KOSAKATA',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1)),
                        const SizedBox(height: 8),
                        for (final w in k.contoh)
                          _contohRow(w, setSheetState),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Text(hafal ? 'Hafal ✓' : 'Belum hafal'),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text('BAB ${k.bab}'),
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );

    // Lompat ke bagian yang diminta setelah sheet terbuka.
    Future.delayed(const Duration(milliseconds: 450), () {
      final key = section == 'bushu'
          ? keyBushu
          : section == 'contoh'
              ? keyContoh
              : section == 'mirip'
                  ? keyMirip
                  : keyAtas;
      scrollTo(key);
    });
  }

  Widget _sheetPill(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _componentCard(KanjiComponent c, String selfKanji) {
    final others = kanjiWithComponent(c.kanji, selfKanji);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _slate,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(c.kanji,
                      style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.isBushu
                                ? _slate
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(c.isBushu ? 'BUSYU 部首' : 'KOMPONEN LAIN',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: c.isBushu
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if (c.position.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(c.position,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${c.reading} (${c.arti})',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoBox(
            title: 'KANJI DENGAN ${c.kanji} BIASANYA TENTANG',
            body: c.theme,
          ),
          const SizedBox(height: 8),
          _infoBox(
            title: '💡 CARA MENGINGAT',
            body: c.caraIngat,
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('KANJI LAIN DI DECK-MU DENGAN ${c.kanji}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: others
                  .map((o) => InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Future.delayed(
                              const Duration(milliseconds: 200),
                              () => _showKanjiDetail(o));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 64,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Text(o.kanji,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Text(o.arti,
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoBox({
    required String title,
    required String body,
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFEE2E2) : const Color(0xFFE8ECF1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: highlight
                      ? const Color(0xFFB91C1C)
                      : Colors.grey.shade700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _contohRow(ContohKata w, void Function(void Function()) setSheetState) {
    final hafal = widget.state.isKosakataHafal(w.kata);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.reading,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFB91C1C))),
                  Text(w.kata,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(w.arti,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                widget.state.toggleKosakataHafal(w.kata);
                setSheetState(() {});
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      hafal ? const Color(0xFF15803D) : Colors.transparent,
                  border: Border.all(
                      color: hafal
                          ? const Color(0xFF15803D)
                          : Colors.grey.shade400),
                ),
                child: hafal
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : const Icon(Icons.add, size: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
