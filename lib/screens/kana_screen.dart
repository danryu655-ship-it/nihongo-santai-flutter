import 'dart:math';

import 'package:flutter/material.dart';

import '../data/kana.dart';
import '../services/store.dart';
import '../services/school_sync.dart';
import '../services/tts_service.dart';
import '../widgets.dart';

/// Tab Kana: belajar Hiragana & Katakana — grid huruf dengan progress per
/// huruf, ketuk huruf untuk mendengarnya, plus mode kuis dua arah.
class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key, required this.state});

  final AppState state;

  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaScreenState extends State<KanaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? _tapped; // huruf terakhir yang diketuk (highlight)
  _Quiz? _quiz; // null = tampil grid, tidak null = mode kuis

  static const List<KanaChar> _hiraganaAll = [...hiragana, ...hiraganaDakuten];
  static const List<KanaChar> _katakanaAll = [...katakana, ...katakanaDakuten];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() => _tapped = null);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<KanaChar> get _currentAll =>
      _tabs.index == 0 ? _hiraganaAll : _katakanaAll;

  Future<void> _speak(String kana) async {
    setState(() => _tapped = kana);
    final ok = await TtsService.instance.speak(kana);
    if (!mounted) return;
    if (!ok) {
      showMsg(
        context,
        'Tidak ada suara Jepang di HP ini. Aktifkan Google Text-to-Speech bahasa Jepang di pengaturan HP.',
      );
    }
  }

  void _startQuiz() {
    setState(() => _quiz = _Quiz(_currentAll));
  }

  @override
  Widget build(BuildContext context) {
    if (_quiz != null) {
      return _QuizView(
        quiz: _quiz!,
        state: widget.state,
        onExit: () => setState(() => _quiz = null),
      );
    }
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return Column(
          children: [
            TabBar(
              controller: _tabs,
              labelColor: brand,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: brand,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'HIRAGANA'),
                Tab(text: 'KATAKANA'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildScriptTab(
                    title: 'Yuk, belajar Hiragana!',
                    subtitle:
                        'Pelajari sistem penulisan utama dalam bahasa Jepang',
                    basic: hiragana,
                    dakuten: hiraganaDakuten,
                  ),
                  _buildScriptTab(
                    title: 'Yuk, belajar Katakana!',
                    subtitle:
                        'Latih karakter-karakter yang digunakan untuk kata pinjaman',
                    basic: katakana,
                    dakuten: katakanaDakuten,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScriptTab({
    required String title,
    required String subtitle,
    required List<KanaChar> basic,
    required List<KanaChar> dakuten,
  }) {
    final all = [...basic, ...dakuten];
    final mastered =
        all.where((c) => widget.state.kanaMastery(c.kana) >= 1).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          '$mastered dari ${all.length} huruf dikuasai',
          style: const TextStyle(
            fontSize: 13,
            color: brand,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'PELAJARI KARAKTERNYA',
          icon: Icons.play_arrow,
          onPressed: _startQuiz,
        ),
        const SizedBox(height: 8),
        _buildSection('Dasar', basic),
        _buildSection('Dakuten', dakuten),
      ],
    );
  }

  Widget _buildSection(String label, List<KanaChar> chars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(label),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.82,
          children: chars.map(_buildCell).toList(),
        ),
      ],
    );
  }

  Widget _buildCell(KanaChar c) {
    final mastery = widget.state.kanaMastery(c.kana);
    final active = _tapped == c.kana;
    return InkWell(
      onTap: () => _speak(c.kana),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: active ? brandLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? brand : Colors.grey.shade300,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              c.kana,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              c.romaji,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LinearProgressIndicator(
                value: mastery,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  mastery >= 1 ? okGreen : brand,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Mode kuis ----------------

/// Satu soal kuis kana.
class _QuizQuestion {
  const _QuizQuestion({
    required this.target,
    required this.kanaFirst,
    required this.options,
  });

  /// Huruf yang ditanyakan.
  final KanaChar target;

  /// true: tampil kana, pilih romaji. false: tampil romaji, pilih kana.
  final bool kanaFirst;

  /// 4 pilihan jawaban (romaji bila [kanaFirst], kana bila tidak).
  final List<String> options;
}

/// Kuis 10 soal dari satu set huruf.
class _Quiz {
  _Quiz(List<KanaChar> pool) {
    final rnd = Random();
    // Satu romaji hanya diwakili satu huruf (misal じ dan ぢ sama-sama "ji").
    final unique = <String, KanaChar>{};
    for (final c in pool) {
      unique.putIfAbsent(c.romaji, () => c);
    }
    final chars = unique.values.toList()..shuffle(rnd);
    final picked = chars.take(10).toList();
    for (final target in picked) {
      final kanaFirst = rnd.nextBool();
      final others = chars
          .where((c) => c.romaji != target.romaji)
          .toList()
        ..shuffle(rnd);
      final distract = others.take(3).toList();
      final options = kanaFirst
          ? [target.romaji, ...distract.map((c) => c.romaji)]
          : [target.kana, ...distract.map((c) => c.kana)];
      options.shuffle(rnd);
      questions.add(
        _QuizQuestion(
          target: target,
          kanaFirst: kanaFirst,
          options: options,
        ),
      );
    }
  }

  final List<_QuizQuestion> questions = [];
}

class _QuizView extends StatefulWidget {
  const _QuizView({
    required this.quiz,
    required this.state,
    required this.onExit,
  });

  final _Quiz quiz;
  final AppState state;
  final VoidCallback onExit;

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  int _index = 0;
  String? _picked;
  int _score = 0;
  bool _done = false;

  _QuizQuestion get _q => widget.quiz.questions[_index];

  bool get _answered => _picked != null;

  String get _correctAnswer =>
      _q.kanaFirst ? _q.target.romaji : _q.target.kana;

  @override
  void initState() {
    super.initState();
    _speakCurrent();
  }

  void _speakCurrent() {
    // Ucapkan huruf soal saat soal tampil (mode kana -> romaji).
    if (_q.kanaFirst) {
      TtsService.instance.speak(_q.target.kana);
    }
  }

  void _answer(String option) {
    if (_answered) return;
    final correct = option == _correctAnswer;
    setState(() {
      _picked = option;
      if (correct) {
        _score++;
        widget.state.addXp(2);
      }
    });
    widget.state.bumpKana(_q.target.kana, correct);
    TtsService.instance.speak(_q.target.kana);
  }

 void _next() {
    if (_index + 1 >= widget.quiz.questions.length) {
      // Kuis Kana selesai — kirim XP terbaru ke Sekolah.
      SchoolSyncService.instance.syncNow(widget.state);
      setState(() => _done = true);
    } else {
      setState(() {
        _index++;
        _picked = null;
      });
      _speakCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildResult();
    final total = widget.quiz.questions.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onExit,
              icon: const Icon(Icons.close),
              tooltip: 'Keluar dari kuis',
            ),
            const SizedBox(width: 4),
            Text(
              'Soal ${_index + 1} dari $total',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: brand,
              ),
            ),
            const Spacer(),
            Text(
              'Skor: $_score',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        LinearProgressIndicator(
          value: (_index + (_answered ? 1 : 0)) / total,
          minHeight: 6,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(brand),
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 28),
        Text(
          _q.kanaFirst
              ? 'Huruf ini dibaca apa?'
              : 'Romaji ini ditulis kana apa?',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => TtsService.instance.speak(_q.target.kana),
          child: Text(
            _q.kanaFirst ? _q.target.kana : _q.target.romaji,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, size: 16, color: brand),
            SizedBox(width: 4),
            Text(
              'Ketuk huruf untuk mendengarnya',
              style: TextStyle(fontSize: 13, color: brand),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: _q.options.map(_buildOption).toList(),
        ),
        const SizedBox(height: 20),
        if (_answered) ...[
          AppCard(
            color: _picked == _correctAnswer
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFEE2E2),
            child: Text(
              _picked == _correctAnswer
                  ? '✅ Benar! “${_q.target.kana}” dibaca “${_q.target.romaji}”.'
                  : '❌ Kurang tepat. “${_q.target.kana}” dibaca “${_q.target.romaji}”.',
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: _index + 1 >= total ? 'LIHAT HASIL' : 'LANJUT',
            onPressed: _next,
          ),
        ],
      ],
    );
  }

  Widget _buildOption(String option) {
    Color? bg;
    Color? border;
    if (_answered) {
      if (option == _correctAnswer) {
        bg = const Color(0xFFDCFCE7);
        border = okGreen;
      } else if (option == _picked) {
        bg = const Color(0xFFFEE2E2);
        border = badRed;
      }
    }
    return InkWell(
      onTap: _answered ? null : () => _answer(option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border ?? Colors.grey.shade300),
        ),
        child: Text(
          option,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final total = widget.quiz.questions.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 40),
        Text(
          _score == total
              ? '🎉 Sempurna!'
              : _score >= total * 0.7
                  ? '👏 Bagus sekali!'
                  : _score >= total * 0.5
                      ? '💪 Lumayan, terus latihan!'
                      : '📚 Terus berlatih ya!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Skor kamu: $_score dari $total',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Huruf yang dijawab benar naik progress-nya di grid.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'KEMBALI KE GRID',
          onPressed: widget.onExit,
        ),
      ],
    );
  }
}
