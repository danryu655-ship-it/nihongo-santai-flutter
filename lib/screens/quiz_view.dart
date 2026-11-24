import 'dart:math';

import 'package:flutter/material.dart';

import '../data/quiz.dart';
import '../services/school_sync.dart';
import '../services/store.dart';
import '../widgets.dart';

/// Kuis pilihan ganda (dipakai hub Belajar & layar Materi).
/// [saveBest] true: simpan skor terbaik (hanya kuis utama Moji-Goi).
class QuizView extends StatefulWidget {
  const QuizView({
    super.key,
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
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
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
          ? '🎉 Sempurna! Semua benar!'
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
