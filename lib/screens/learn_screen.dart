import 'dart:math';

import 'package:flutter/material.dart';

import '../data/konbini.dart';
import '../data/lessons.dart';
import '../data/quiz.dart';
import '../data/dictionary.dart';
import '../data/grammar.dart';
import '../services/store.dart';
import '../services/school_sync.dart';
import '../widgets.dart';
import 'lesson_player.dart';
import 'flashcard_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, required this.state});

  final AppState state;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _view = 'hub'; // hub | lessons | konbini | quiz-moji | quiz-bunpou | kursus | progres

  bool _isUnlocked(int globalIndex) {
    if (globalIndex == 0) return true;
    return widget.state.done.containsKey(lessons[globalIndex - 1].id);
  }

  bool _levelUnlocked(String levelId) {
    final idx = levels.indexWhere((l) => l.id == levelId);
    if (idx <= 0) return true;
    final prev = levels[idx - 1].id;
    return lessons
        .where((l) => l.level == prev)
        .every((l) => widget.state.done.containsKey(l.id));
  }

  bool _levelDone(String levelId) {
    return lessons
        .where((l) => l.level == levelId)
        .every((l) => widget.state.done.containsKey(l.id));
  }

  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case 'lessons':
        return _lessonsView();
      case 'konbini':
        return _konbiniView();
      case 'quiz-moji':
        return _QuizView(
          state: widget.state,
          onBack: () => setState(() => _view = 'hub'),
          title: 'Moji-Goi',
          questions: travelQuiz,
        );
      case 'quiz-bunpou':
        return _QuizView(
          state: widget.state,
          onBack: () => setState(() => _view = 'hub'),
          title: 'Bunpou',
          questions: _bunpouQuestions(),
          saveBest: false,
        );
      case 'kursus':
        return _kursusView();
      case 'progres':
        return _progresView();
      default:
        return _hubView();
    }
  }

  /// Hub Belajar ala Goukaku: header ilustrasi + grid 2x2 + Latihan Soal.
  Widget _hubView() {
    final dark = widget.state.softDark;
    final cardBg = dark ? const Color(0xFF282624) : const Color(0xFFE8ECF1);
    final creamBg = dark ? const Color(0xFF2E2A24) : const Color(0xFFF5EFE3);
    final ink = dark ? const Color(0xFFEAE5DC) : const Color(0xFF1F2A37);
    final sub = dark ? const Color(0xFFB3ACA0) : const Color(0xFF5B6B7C);
    const kursusBg = Color(0xFF3D5A73);
    const amber = Color(0xFFE8C87A);

    void openFlashcard() {
      final cards = (List.of(dictionary)..shuffle()).take(10).map((e) => FlashcardItem(
            kanjiOrKana: e.japanese,
            romaji: e.romaji,
            arti: e.indonesian,
          )).toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardScreen(
            kategori: 'Kosakata Harian',
            customCards: cards,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // --- Header: judul + ilustrasi ---
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF282624) : const Color(0xFFE3EAF2),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Belajar',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ink)),
                      const SizedBox(height: 6),
                      Text('Flashcard, materi, latihan soal, dan ujian JLPT.',
                          style: TextStyle(fontSize: 13.5, color: sub)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  child: Image.asset(
                    'assets/images/belajar-hero.png',
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // --- Grid 2x2 ---
        Row(
          children: [
            Expanded(
              child: _goukakuCard(
                bg: cardBg,
                ink: ink,
                sub: sub,
                jp: '暗記',
                emoji: '🃏',
                title: 'Flashcard',
                subtitle: 'Kosakata & Kanji • 10 kartu acak',
                darkCard: false,
                onTap: openFlashcard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _goukakuCard(
                bg: cardBg,
                ink: ink,
                sub: sub,
                jp: '教材',
                emoji: '📖',
                title: 'Materi',
                subtitle: '48 pelajaran N5–N1',
                darkCard: false,
                onTap: () => setState(() => _view = 'lessons'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _goukakuCard(
                bg: kursusBg,
                ink: Colors.white,
                sub: Colors.white70,
                jp: '目標',
                emoji: '⛰️',
                title: 'Kursus',
                subtitle: 'Susun rencana belajarmu',
                darkCard: true,
                jpColor: amber,
                onTap: () => setState(() => _view = 'kursus'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _goukakuCard(
                bg: creamBg,
                ink: ink,
                sub: sub,
                jp: 'PROGRES',
                emoji: '🏅',
                title: 'MyGoukaku',
                subtitle: 'Skor, riwayat, kesiapan JLPT',
                darkCard: false,
                onTap: () => setState(() => _view = 'progres'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        // --- Latihan Soal ---
        Text('Latihan Soal',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ink)),
        const SizedBox(height: 10),
        _latihanRow(
          bg: cardBg,
          ink: ink,
          sub: sub,
          jp: '文字・語彙',
          emoji: '✏️',
          title: 'Moji-Goi',
          subtitle: '10 soal: kanji, kosakata, pemakaian kata',
          onTap: () => setState(() => _view = 'quiz-moji'),
        ),
        const SizedBox(height: 10),
        _latihanRow(
          bg: cardBg,
          ink: ink,
          sub: sub,
          jp: '文法',
          emoji: '🧩',
          title: 'Bunpou',
          subtitle: '10 soal: tata bahasa dan susunan kalimat',
          onTap: () => setState(() => _view = 'quiz-bunpou'),
        ),
      ],
    );
  }

  /// Kartu grid ala Goukaku: ikon bulat + panah bulat, label JP, judul, subjudul.
  Widget _goukakuCard({
    required Color bg,
    required Color ink,
    required Color sub,
    required String jp,
    required String emoji,
    required String title,
    required String subtitle,
    required bool darkCard,
    Color? jpColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: darkCard
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: darkCard ? Colors.white : const Color(0xFF3D5A73),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: darkCard ? const Color(0xFF3D5A73) : Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(jp,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: jpColor ?? sub)),
            const SizedBox(height: 2),
            Text(title,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: ink)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 13, color: sub)),
          ],
        ),
      ),
    );
  }

  /// Baris Latihan Soal ala Goukaku: ikon bulat + teks + panah bulat.
  Widget _latihanRow({
    required Color bg,
    required Color ink,
    required Color sub,
    required String jp,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jp,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: sub)),
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ink)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: sub)),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF3D5A73),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward,
                  size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Rencana kursus: progres tiap level N5–N1 (data pelajaran yang sudah ada).
  Widget _kursusView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _view = 'hub'),
              icon: const Icon(Icons.arrow_back),
            ),
            const Text('Kursus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const Text(
          'Susun rencana belajarmu — selesaikan pelajaran berurutan untuk membuka level berikutnya.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        for (final lv in levels) ...[
          AppCard(
            onTap: () => setState(() => _view = 'lessons'),
            child: Row(
              children: [
                Text(lv.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${lv.id} — ${lv.description}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: _levelProgress(lv.id),
                        backgroundColor: Colors.grey.shade300,
                        color: brand,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_levelDoneCount(lv.id)}/${lessons.where((l) => l.level == lv.id).length} selesai'
                        '${_levelDone(lv.id) ? ' • 🏅 Master' : _levelUnlocked(lv.id) ? '' : ' • 🔒 Terkunci'}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  double _levelProgress(String levelId) {
    final total = lessons.where((l) => l.level == levelId).length;
    if (total == 0) return 0;
    return _levelDoneCount(levelId) / total;
  }

  int _levelDoneCount(String levelId) {
    return lessons
        .where(
            (l) => l.level == levelId && widget.state.done.containsKey(l.id))
        .length;
  }

  /// Progres belajar (dulu kartu progres di hub): level, XP, streak, pelajaran, skor kuis.
  Widget _progresView() {
    final s = widget.state;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _view = 'hub'),
              icon: const Icon(Icons.arrow_back),
            ),
            const Text('MyGoukaku',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        AppCard(
          color: brandLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level ${s.level}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: s.xpIntoLevel / 100,
                backgroundColor: Colors.white,
                color: brand,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Text(
                '${s.xpIntoLevel} / 100 XP ke level ${s.level + 1} • '
                'Streak 🔥 ${s.streak} hari • ${s.lessonsDone}/48 pelajaran',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Skor terbaik Kuis Travel N5: ${s.quizBest} / 10',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selesaikan pelajaran berurutan untuk membuka yang berikutnya. '
                'Tiap pelajaran 10 soal, 3 hati ❤️ — hati habis berarti gagal dan bisa diulang. '
                'Jawaban benar = +10 XP, pelajaran sempurna = bonus +20 XP.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 10 soal Bunpou acak dari bank soal tata bahasa (mc & fill saja).
  List<QuizQuestion> _bunpouQuestions() {
    final rnd = Random();
    final pool = <QuizQuestion>[];
    for (final list in grammarQuestions.values) {
      for (final g in list) {
        if ((g.type == 'mc' || g.type == 'fill') &&
            g.options != null &&
            g.answerIndex != null) {
          pool.add(QuizQuestion(
            question:
                g.type == 'mc' ? (g.question ?? '') : (g.sentence ?? ''),
            options: g.options!,
            answerIndex: g.answerIndex!,
          ));
        }
      }
    }
    pool.shuffle(rnd);
    return pool.take(10).toList();
  }

  Widget _lessonsView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _view = 'hub'),
              icon: const Icon(Icons.arrow_back),
            ),
            const Text('Pelajaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        for (final lv in levels) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 14, 2, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${lv.icon} ${lv.id} — ${lv.description}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: brand,
                    ),
                  ),
                ),
                if (_levelDone(lv.id))
                  const Chip(
                    label: Text('🏅 Master',
                        style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  )
                else if (!_levelUnlocked(lv.id))
                  const Text('🔒 Selesaikan level sebelumnya',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          for (final l in lessons.where((x) => x.level == lv.id))
            _lessonRow(l),
        ],
      ],
    );
  }

  Widget _lessonRow(Lesson l) {
    final idx = lessons.indexOf(l);
    final locked = !_isUnlocked(idx);
    final doneScore = widget.state.done[l.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        color: locked ? Colors.grey.shade100 : Colors.white,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: brandLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(l.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${l.track} • ${l.description}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  if (l.intro != null)
                    const Text('📖 Ada penjelasan materi di awal pelajaran.',
                        style: TextStyle(fontSize: 11, color: brand)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (doneScore != null)
              Chip(
                label: Text('✅ $doneScore/10',
                    style: const TextStyle(fontSize: 11)),
                backgroundColor: const Color(0xFFDCFCE7),
                visualDensity: VisualDensity.compact,
              )
            else if (locked)
              const Text('🔒', style: TextStyle(fontSize: 18))
            else
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonPlayerPage(
                        lesson: l,
                        state: widget.state,
                      ),
                    ),
                  );
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Mulai'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _konbiniView() {
    final doneCount = widget.state.konbiniDone.length;
    final badge = doneCount >= 30
        ? '🏅 Badge 30 item!'
        : doneCount >= 20
            ? '🏅 Badge 20 item!'
            : doneCount >= 10
                ? '🏅 Badge 10 item!'
                : 'Centang 10 item untuk badge pertama.';
    final cats = <String>[];
    for (final item in konbiniItems) {
      if (!cats.contains(item.category)) cats.add(item.category);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _view = 'hub'),
              icon: const Icon(Icons.arrow_back),
            ),
            const Text('Konbini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        AppCard(
          color: brandLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$doneCount / 33 item dicentang',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: doneCount / 33,
                backgroundColor: Colors.white,
                color: brand,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Text(badge, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        for (final c in cats) ...[
          SectionTitle(c, icon: '🏪'),
          for (var i = 0; i < konbiniItems.length; i++)
            if (konbiniItems[i].category == c)
              CheckboxListTile(
                value: widget.state.konbiniDone.contains(i),
                onChanged: (_) {
                  widget.state.toggleKonbini(i);
                  setState(() {});
                },
                title: Text(konbiniItems[i].japanese,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${konbiniItems[i].romaji} • ${konbiniItems[i].indonesian}'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
        ],
      ],
    );
  }
}

// ---------------- Kuis Travel N5 ----------------

class _QuizView extends StatefulWidget {
  const _QuizView({
    required this.state,
    required this.onBack,
    required this.title,
    required this.questions,
    this.saveBest = true,
  });

  final AppState state;
  final VoidCallback onBack;

  /// Judul tampil (mis. 'Moji-Goi' / 'Bunpou').
  final String title;

  /// Bank soal (diacak di _start).
  final List<QuizQuestion> questions;

  /// true: simpan skor terbaik (hanya kuis utama).
  final bool saveBest;

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  List<QuizQuestion> _qs = [];
  int _idx = 0;
  int _score = 0;
  int? _picked;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final rnd = Random();
    _qs = widget.questions.map((q) {
      final opts = [...q.options]..shuffle(rnd);
      return QuizQuestion(
        question: q.question,
        options: opts,
        answerIndex: opts.indexOf(q.options[q.answerIndex]),
      );
    }).toList()
      ..shuffle(rnd);
    _idx = 0;
    _score = 0;
    _picked = null;
    _finished = false;
  }

  void _answer(int i) {
    if (_picked != null) return;
    setState(() {
      _picked = i;
      if (i == _qs[_idx].answerIndex) _score++;
    });
  }

  void _next() {
    if (_idx + 1 >= _qs.length) {
      if (widget.saveBest) {
        widget.state.setQuizBest(_score);
        // Kuis selesai — kirim snapshot progres terbaru ke Sekolah.
        SchoolSyncService.instance.syncNow(widget.state);
      }
      setState(() => _finished = true);
    } else {
      setState(() {
        _idx++;
        _picked = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final msg = _score == 10
          ? '🎉 Sempurna! Nilaimu 10/10!'
          : _score >= 7
              ? '👏 Bagus sekali! Tinggal sedikit lagi.'
              : _score >= 4
                  ? '🙂 Lumayan — coba lagi, pasti naik.'
                  : '💪 Jangan menyerah — coba lagi, pasti naik.';
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AppCard(
            child: Column(
              children: [
                const Text('🏁', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text('Skor: $_score / ${_qs.length}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(msg, textAlign: TextAlign.center),
                if (widget.saveBest) ...[
                  const SizedBox(height: 8),
                  Text('Skor terbaik: ${widget.state.quizBest} / 10',
                      style: const TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Main lagi',
                  icon: Icons.refresh,
                  onPressed: () => setState(_start),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Kembali ke Belajar'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final q = _qs[_idx];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            Text(widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Text('Soal ${_idx + 1} dari ${_qs.length} • Skor: $_score',
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 10),
        AppCard(
          child: Text(q.question,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _picked == null ? () => _answer(i) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _picked == null
                      ? Colors.white
                      : i == q.answerIndex
                          ? const Color(0xFFDCFCE7)
                          : i == _picked
                              ? const Color(0xFFFEE2E2)
                              : Colors.white,
                  foregroundColor: Colors.black87,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Text(q.options[i], style: const TextStyle(fontSize: 15)),
              ),
            ),
          ),
        if (_picked != null) ...[
          Text(
            _picked == q.answerIndex
                ? '✅ Benar!'
                : '❌ Jawaban benar: ${q.options[q.answerIndex]}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _picked == q.answerIndex ? okGreen : badRed,
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: _idx + 1 >= _qs.length ? 'Lihat Hasil' : 'Soal Berikutnya',
            onPressed: _next,
          ),
        ],
      ],
    );
  }
}
