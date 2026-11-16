import 'dart:math';

import 'package:flutter/material.dart';

import '../data/dictionary.dart';
import '../data/grammar.dart';
import '../data/kana.dart';
import '../data/lessons.dart';
import '../services/store.dart';
import '../services/school_sync.dart';
import '../services/tts_service.dart';
import '../widgets.dart';

List<T> _sample<T>(List<T> src, int n, Random rnd) {
  final c = [...src]..shuffle(rnd);
  return c.take(n.clamp(0, src.length)).toList();
}

/// Satu soal yang sudah diacak & siap ditampilkan.
class _Q {
  _Q({
    required this.type,
    required this.prompt,
    this.big = '',
    this.sub = '',
    this.options = const [],
    this.answer = '',
    this.note = '',
    this.speak,
    this.words = const [],
    this.pairs = const [],
  });

  final String type; // mc | arrange | match
  final String prompt;
  final String big;
  final String sub;
  final List<String> options;
  final String answer;
  final String note;
  final String? speak;
  final List<String> words; // arrange: urutan benar
  final List<(String, String)> pairs; // match: (jepang, arti)
}

class LessonPlayerPage extends StatefulWidget {
  const LessonPlayerPage({
    super.key,
    required this.lesson,
    required this.state,
  });

  final Lesson lesson;
  final AppState state;

  @override
  State<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends State<LessonPlayerPage> {
  late final List<_Q> _qs;
  int _idx = 0;
  int _hearts = 3;
  int _xpLesson = 0;
  bool _lostHeart = false;
  bool _answered = false;
  int? _picked;
  String _feedback = '';
  bool _finished = false;
  bool _passed = false;

  // arrange
  List<String> _pool = [];
  List<int> _selected = [];

  // match
  List<String> _mLeft = [];
  List<String> _mRight = [];
  int? _selL;
  int? _selR;
  final Set<int> _matchedL = {};
  final Set<int> _matchedR = {};
  int? _wrongL;
  int? _wrongR;

  @override
  void initState() {
    super.initState();
    _qs = _buildQuestions(widget.lesson);
    _setupQuestion();
  }

  List<_Q> _buildQuestions(Lesson l) {
    final rnd = Random();
    final qs = <_Q>[];
    if (l.kind == 'kana') {
      final table = l.script == 'k' ? katakana : hiragana;
      final picks = _sample(l.kanaSet ?? <KanaChar>[], 10, rnd);
      for (var i = 0; i < picks.length; i++) {
        final k = picks[i];
        if (i % 2 == 0) {
          final distract = _sample(
            table.where((x) => x.romaji != k.romaji).toList(),
            3,
            rnd,
          ).map((x) => x.romaji).toList();
          final opts = [k.romaji, ...distract]..shuffle(rnd);
          qs.add(_Q(
            type: 'mc',
            prompt: 'Huruf ini dibaca apa?',
            big: k.kana,
            options: opts,
            answer: k.romaji,
            note: '“${k.kana}” dibaca “${k.romaji}”.',
            speak: k.kana,
          ));
        } else {
          final distract = _sample(
            table.where((x) => x.kana != k.kana && x.romaji != k.romaji).toList(),
            3,
            rnd,
          ).map((x) => x.kana).toList();
          final opts = [k.kana, ...distract]..shuffle(rnd);
          qs.add(_Q(
            type: 'mc',
            prompt: 'Romaji “${k.romaji}” ditulis kana apa?',
            big: k.romaji,
            options: opts,
            answer: k.kana,
            note: '“${k.romaji}” = “${k.kana}”.',
            speak: k.kana,
          ));
        }
      }
    } else if (l.kind == 'vocab') {
      final cats = l.categories ?? [];
      final pool = dictionary
          .where((e) => cats.contains(e.category))
          .toList();
      final picks = _sample(pool, 9, rnd);
      for (var i = 0; i < picks.length; i++) {
        final w = picks[i];
        final mode = i % 3;
        if (mode == 0) {
          final d = _sample(
            pool.where((x) => x.japanese != w.japanese).toList(),
            3,
            rnd,
          ).map((x) => x.indonesian).toList();
          final opts = [w.indonesian, ...d]..shuffle(rnd);
          qs.add(_Q(
            type: 'mc',
            prompt: 'Apa arti kata ini?',
            big: w.japanese,
            sub: '${w.kana} • ${w.romaji}',
            options: opts,
            answer: w.indonesian,
            note: '“${w.japanese}” (${w.romaji}) = ${w.indonesian}.',
            speak: w.japanese,
          ));
        } else if (mode == 1) {
          final d = _sample(
            pool.where((x) => x.japanese != w.japanese).toList(),
            3,
            rnd,
          ).map((x) => x.japanese).toList();
          final opts = [w.japanese, ...d]..shuffle(rnd);
          qs.add(_Q(
            type: 'mc',
            prompt: '“${w.indonesian}” dalam bahasa Jepang?',
            big: w.indonesian,
            options: opts,
            answer: w.japanese,
            note: '“${w.indonesian}” = “${w.japanese}” (${w.romaji}).',
            speak: w.japanese,
          ));
        } else {
          final d = _sample(
            pool.where((x) => x.japanese != w.japanese).toList(),
            3,
            rnd,
          ).map((x) => x.japanese).toList();
          final opts = [w.japanese, ...d]..shuffle(rnd);
          qs.add(_Q(
            type: 'mc',
            prompt: 'Romaji “${w.romaji}” ditulis apa?',
            big: w.romaji,
            options: opts,
            answer: w.japanese,
            note: '“${w.romaji}” = “${w.japanese}” (${w.kana}).',
            speak: w.japanese,
          ));
        }
      }
      final mp = _sample(pool, 4, rnd);
      qs.insert(
        4.clamp(0, qs.length),
        _Q(
          type: 'match',
          prompt: 'Jodohkan kata dengan artinya — ketuk satu dari kiri, lalu pasangannya di kanan:',
          pairs: mp.map((w) => (w.japanese, w.indonesian)).toList(),
        ),
      );
    } else {
      final bank = grammarQuestions[l.grammarId] ?? [];
      final picks = _sample(bank, 10, rnd);
      for (final q in picks) {
        if (q.type == 'mc') {
          final opts = [...(q.options ?? <String>[])]..shuffle(rnd);
          qs.add(_Q(
            type: 'mc',
            prompt: q.question ?? '',
            options: opts,
            answer: (q.options ?? [])[q.answerIndex ?? 0],
            note: q.note ?? '',
          ));
        } else if (q.type == 'fill') {
          final opts = [...(q.options ?? <String>[])]..shuffle(rnd);
          qs.add(_Q(
            type: 'mc',
            prompt: 'Lengkapi kalimat ini:',
            big: q.sentence ?? '',
            options: opts,
            answer: (q.options ?? [])[q.answerIndex ?? 0],
            note: q.note ?? '',
          ));
        } else {
          // arrange: w = urutan benar
          qs.add(_Q(
            type: 'arrange',
            prompt: 'Susun kata-kata ini menjadi kalimat yang benar:',
            words: [...(q.words ?? [])],
            note: q.note ?? '',
          ));
        }
      }
    }
    return qs.take(10).toList();
  }

  void _setupQuestion() {
    final q = _qs[_idx];
    _answered = false;
    _picked = null;
    _feedback = '';
    _selected = [];
    _pool = [...q.words]..shuffle(Random());
    _selL = null;
    _selR = null;
    _matchedL.clear();
    _matchedR.clear();
    _wrongL = null;
    _wrongR = null;
    if (q.type == 'match') {
      _mLeft = q.pairs.map((p) => p.$1).toList()..shuffle(Random());
      _mRight = q.pairs.map((p) => p.$2).toList()..shuffle(Random());
    }
  }

  void _finishAnswer(bool ok, String msg) {
    if (ok) {
      _xpLesson += 10;
      widget.state.addXp(10);
    } else {
      _hearts--;
      _lostHeart = true;
    }
    setState(() {
      _answered = true;
      _feedback = msg;
    });
  }

  void _answerMc(int i) {
    if (_answered) return;
    final q = _qs[_idx];
    final chosen = q.options[i];
    final ok = chosen == q.answer;
    setState(() => _picked = i);
    _finishAnswer(
      ok,
      ok ? 'Benar! 🎉' : 'Jawaban benar: ${q.answer}',
    );
  }

  void _checkArrange() {
    final q = _qs[_idx];
    if (_selected.length != q.words.length) {
      setState(() => _feedback = 'Pakai semua kata dulu.');
      return;
    }
    final got = _selected.map((i) => _pool[i]).toList();
    final ok = got.join('|') == q.words.join('|');
    _finishAnswer(
      ok,
      ok ? 'Benar! 🎉' : 'Jawaban benar: ${q.words.join(' ')}',
    );
  }

  void _onMatchTap(String side, int i) {
    if (_answered) return;
    setState(() {
      if (side == 'l') {
        if (_matchedL.contains(i)) return;
        _selL = i;
      } else {
        if (_matchedR.contains(i)) return;
        _selR = i;
      }
      if (_selL != null && _selR != null) {
        final lv = _mLeft[_selL!];
        final rv = _mRight[_selR!];
        final q = _qs[_idx];
        final correct = q.pairs.any((p) => p.$1 == lv && p.$2 == rv);
        if (correct) {
          _matchedL.add(_selL!);
          _matchedR.add(_selR!);
          _selL = null;
          _selR = null;
          if (_matchedL.length == q.pairs.length) {
            _finishAnswer(true, 'Semua pasangan benar! 🎉');
          }
        } else {
          _wrongL = _selL;
          _wrongR = _selR;
          final wl = _selL, wr = _selR;
          _selL = null;
          _selR = null;
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            setState(() {
              if (_wrongL == wl) _wrongL = null;
              if (_wrongR == wr) _wrongR = null;
            });
          });
        }
      }
    });
  }

  void _next() {
    if (_hearts <= 0) {
      _end(false);
      return;
    }
    if (_idx + 1 >= _qs.length) {
      _end(true);
      return;
    }
    setState(() {
      _idx++;
      _setupQuestion();
    });
  }

  void _end(bool passed) {
    var bonus = 0;
    if (passed) {
      if (!_lostHeart) {
        bonus = 20;
        widget.state.addXp(20);
      }
      widget.state.completeLesson(widget.lesson.id);
      // Kirim progres ke Sekolah (fire-and-forget; gagal = antre, tidak crash).
      SchoolSyncService.instance.syncNow(widget.state);
    }
    setState(() {
      _finished = true;
      _passed = passed;
      if (bonus > 0) _xpLesson += bonus;
    });
  }

  Future<void> _speak(String text) async {
    final ok = await TtsService.instance.speak(text);
    if (!mounted) return;
    if (!ok) {
      showMsg(
        context,
        'Tidak ada suara Jepang di HP ini. Aktifkan Google Text-to-Speech bahasa Jepang di pengaturan HP.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.title),
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
      body: _finished ? _resultView() : _playView(),
    );
  }

  Widget _resultView() {
    final l = widget.lesson;
    final levelDone = lessons
        .where((x) => x.level == l.level)
        .every((x) => widget.state.done.containsKey(x.id));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            children: [
              Text(_passed ? '🎉' : '💔',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                _passed ? 'Pelajaran selesai!' : 'Hati habis — coba lagi',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _passed
                    ? 'Kamu menyelesaikan "${l.title}" dan mendapat $_xpLesson XP${_lostHeart ? '' : ' (termasuk bonus sempurna +20 XP)'}. Pelajaran berikutnya sudah terbuka. Streak harianmu: 🔥 ${widget.state.streak} hari.'
                    : 'Kamu kehabisan hati di "${l.title}". Tidak apa-apa, ulangi saja pelajarannya — XP yang sudah didapat tetap tersimpan.',
                textAlign: TextAlign.center,
              ),
              if (_passed && levelDone) ...[
                const SizedBox(height: 10),
                Text(
                  '🏅 Level ${l.level} selesai! Kamu mendapat badge ${l.level} Master!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Kembali ke daftar pelajaran',
                onPressed: () => Navigator.of(context).pop(),
              ),
              if (!_passed) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _qs.clear();
                      _qs.addAll(_buildQuestions(l));
                      _idx = 0;
                      _hearts = 3;
                      _xpLesson = 0;
                      _lostHeart = false;
                      _finished = false;
                      _setupQuestion();
                    });
                  },
                  child: const Text('Coba lagi'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _playView() {
    final l = widget.lesson;
    final q = _qs[_idx];
    final heartsStr =
        '❤️' * _hearts.clamp(0, 3) + '🤍' * (3 - _hearts.clamp(0, 3));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (l.kind == 'kana' && l.kanaSet != null) ...[
          AppCard(
            color: brandLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Huruf di pelajaran ini:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: l.kanaSet!
                      .map(
                        (k) => Chip(
                          label: Text('${k.kana}  ${k.romaji}',
                              style: const TextStyle(fontSize: 14)),
                          backgroundColor: Colors.white,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (l.intro != null) ...[
          AppCard(
            child: Text(l.intro!, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                'Soal ${_idx + 1}/${_qs.length} • $_xpLesson XP',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Text(heartsStr, style: const TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: _idx / _qs.length,
          backgroundColor: Colors.grey.shade200,
          color: brand,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(q.prompt,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  if (q.speak != null)
                    IconButton(
                      tooltip: 'Dengarkan',
                      onPressed: () => _speak(q.speak!),
                      icon: const Icon(Icons.volume_up, color: brand),
                    ),
                ],
              ),
              if (q.big.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    q.big,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (q.sub.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(q.sub,
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (q.type == 'mc') ..._mcOptions(q),
        if (q.type == 'arrange') ..._arrangeArea(q),
        if (q.type == 'match') ..._matchArea(q),
        if (_feedback.isNotEmpty) ...[
          const SizedBox(height: 10),
          AppCard(
            color: _answered
                ? (_feedback.startsWith('Benar') ||
                        _feedback.startsWith('Semua')
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2))
                : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _feedback,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _answered
                        ? (_feedback.startsWith('Benar') ||
                                _feedback.startsWith('Semua')
                            ? okGreen
                            : badRed)
                        : Colors.black87,
                  ),
                ),
                if (_answered && q.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(q.note,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keluar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: _hearts <= 0
                    ? 'Lihat hasil'
                    : (_idx + 1 >= _qs.length ? 'Lihat hasil' : 'Lanjut'),
                onPressed: _answered ? _next : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _mcOptions(_Q q) {
    return [
      for (var i = 0; i < q.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _answered ? null : () => _answerMc(i),
              style: ElevatedButton.styleFrom(
                backgroundColor: _answered
                    ? (q.options[i] == q.answer
                        ? const Color(0xFFDCFCE7)
                        : i == _picked
                            ? const Color(0xFFFEE2E2)
                            : Colors.white)
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
    ];
  }

  List<Widget> _arrangeArea(_Q q) {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: brandLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selected.isEmpty
              ? [
                  const Text('Ketuk kata di bawah untuk menyusun…',
                      style: TextStyle(color: Colors.grey)),
                ]
              : _selected
                  .asMap()
                  .entries
                  .map(
                    (e) => ActionChip(
                      label: Text(_pool[e.value]),
                      onPressed: _answered
                          ? null
                          : () => setState(() => _selected.removeAt(e.key)),
                    ),
                  )
                  .toList(),
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _pool.asMap().entries.map((e) {
          final used = _selected.contains(e.key);
          return ElevatedButton(
            onPressed: (_answered || used)
                ? null
                : () => setState(() => _selected.add(e.key)),
            style: ElevatedButton.styleFrom(
              backgroundColor: used ? Colors.grey.shade200 : Colors.white,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(e.value, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
      ),
      const SizedBox(height: 12),
      PrimaryButton(
        label: 'Periksa',
        onPressed: _answered ? null : _checkArrange,
      ),
    ];
  }

  List<Widget> _matchArea(_Q q) {
    Widget col(String side, List<String> items) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.asMap().entries.map((e) {
            final i = e.key;
            final isMatched =
                side == 'l' ? _matchedL.contains(i) : _matchedR.contains(i);
            final isSel = side == 'l' ? _selL == i : _selR == i;
            final isWrong = side == 'l' ? _wrongL == i : _wrongR == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed:
                    (_answered || isMatched) ? null : () => _onMatchTap(side, i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMatched
                      ? const Color(0xFFDCFCE7)
                      : isWrong
                          ? const Color(0xFFFEE2E2)
                          : isSel
                              ? brandLight
                              : Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSel ? brand : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Text(e.value,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center),
              ),
            );
          }).toList(),
        ),
      );
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          col('l', _mLeft),
          const SizedBox(width: 10),
          col('r', _mRight),
        ],
      ),
      Text(
        '${_matchedL.length} / ${q.pairs.length} pasangan benar',
        style: const TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ];
  }
}
