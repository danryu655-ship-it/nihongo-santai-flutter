import 'dart:math';

import 'package:flutter/material.dart';

import '../data/konbini.dart';
import '../data/lessons.dart';
import '../data/quiz.dart';
import '../data/dictionary.dart';
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
  String _view = 'hub'; // hub | lessons | konbini | quiz

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
      case 'quiz':
        return _QuizView(state: widget.state, onBack: () => setState(() => _view = 'hub'));
      default:
        return _hubView();
    }
  }

  Widget _hubView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        AppCard(
          onTap: () => setState(() => _view = 'lessons'),
          child: Row(
            children: [
              const Text('🎓', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Belajar',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Pelajaran N5–N1 • XP, hati & streak',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          onTap: () => setState(() => _view = 'konbini'),
          child: Row(
            children: [
              const Text('🏪', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Konbini',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Checklist 33 item • ${widget.state.konbiniDone.length}/33 dicentang',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          onTap: () => setState(() => _view = 'quiz'),
          child: Row(
            children: [
              const Text('❓', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kuis Travel N5',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '10 soal • Skor terbaik: ${widget.state.quizBest}/10',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          onTap: () {
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
          },
          child: Row(
            children: [
              const Text('🃏', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Flashcard',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Kosakata Harian • ketuk untuk membalik',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: widget.state,
          builder: (context, _) {
            final s = widget.state;
            return AppCard(
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
                  const Text(
                    'Selesaikan pelajaran berurutan untuk membuka yang berikutnya. '
                    'Tiap pelajaran 10 soal, 3 hati ❤️ — hati habis berarti gagal dan bisa diulang. '
                    'Jawaban benar = +10 XP, pelajaran sempurna = bonus +20 XP.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
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
  const _QuizView({required this.state, required this.onBack});

  final AppState state;
  final VoidCallback onBack;

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
    _qs = travelQuiz.map((q) {
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
      widget.state.setQuizBest(_score);
      // Kuis selesai — kirim snapshot progres terbaru ke Sekolah.
      SchoolSyncService.instance.syncNow(widget.state);
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
          ? '🎉 Sempurna! Kamu siap jalan-jalan ke Jepang!'
          : _score >= 7
              ? '👏 Bagus sekali! Tinggal sedikit lagi.'
              : _score >= 4
                  ? '🙂 Lumayan — coba lagi, pasti naik.'
                  : '💪 Jangan menyerah — baca Kartu Frasa dulu lalu coba lagi.';
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
                const SizedBox(height: 8),
                Text('Skor terbaik: ${widget.state.quizBest} / 10',
                    style: const TextStyle(color: Colors.grey)),
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
            const Text('Kuis Travel N5',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
