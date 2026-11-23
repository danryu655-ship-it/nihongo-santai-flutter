import 'dart:math';
import 'package:flutter/material.dart';

class FlashcardItem {
  final String kanjiOrKana;
  final String romaji;
  final String arti;
  final String? kalimatKasual;
  final String? kalimatSopan;
  final String? konteks;

  FlashcardItem({
    required this.kanjiOrKana,
    required this.romaji,
    required this.arti,
    this.kalimatKasual,
    this.kalimatSopan,
    this.konteks,

  });
}

class FlashcardScreen extends StatefulWidget {
  final String kategori;
  final List<FlashcardItem>? customCards;

  const FlashcardScreen({
    Key? key,
    this.kategori = 'Kosakata Santai',
    this.customCards,
  }) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isFront = true;
  bool _isSoftDark = true; // Default nyaman untuk belajar malam hari
  int _currentIndex = 0;
  late List<FlashcardItem> _cards;

  // Palet warna lembut (tidak terlalu kontras/silau)
  static const Color _lightBg = Color(0xFFF7F5F0); // Warm off-white
  static const Color _lightSurface = Color(0xFFECE8DF);
  static const Color _lightText = Color(0xFF262422);

  static const Color _darkBg = Color(0xFF1C1B1A); // Warm charcoal
  static const Color _darkSurface = Color(0xFF282624);
  static const Color _darkText = Color(0xFFEAE5DC);

  static const Color _accent = Color(0xFFD97757); // Terracotta lembut

  @override
  void initState() {
    super.initState();
    _cards = widget.customCards ??
        [
          FlashcardItem(
            kanjiOrKana: 'ありがとう',
            romaji: 'Arigatou',
            arti: 'Terima kasih',
            kalimatKasual: 'ありがとね！(Arigato ne!)',
            kalimatSopan: 'ありがとうございます。(Arigatou gozaimasu.)',
            konteks:
                'Bentuk kasual dipakai ke teman dekat atau adik/keluarga; bentuk sopan dipakai ke rekan kerja, kasir, atau orang baru.',
          ),
          FlashcardItem(
            kanjiOrKana: '食べる',
            romaji: 'Taberu',
            arti: 'Makan',
            kalimatKasual: 'もう食べた？(Mou tabeta?)',
            kalimatSopan: 'もう食べましたか？(Mou tabemashita ka?)',
            konteks:
                'Dipakai saat menanyakan apakah lawan bicara sudah makan siang/malam, misalnya saat ngobrol santai atau istirahat.',
          ),
          FlashcardItem(
            kanjiOrKana: '大丈夫',
            romaji: 'Daijoubu',
            arti: 'Tidak apa-apa / aman',
            kalimatKasual: '大丈夫だよ。(Daijoubu da yo.)',
            kalimatSopan: '大丈夫ですよ。(Daijoubu desu yo.)',
            konteks:
                'Dipakai untuk menenangkan teman saat ada kendala kecil atau menolak tawaran bantuan dengan halus.',
          ),
          FlashcardItem(
            kanjiOrKana: '行く',
            romaji: 'Iku',
            arti: 'Pergi',
            kalimatKasual: '一緒に行く？(Issho ni iku?)',
            kalimatSopan: '一緒に行きますか？(Issho ni ikimasu ka?)',
            konteks:
                'Cocok saat mengajak teman ke kafe, stasiun, atau pulang bareng.',
          ),
          FlashcardItem(
            kanjiOrKana: 'わかる',
            romaji: 'Wakaru',
            arti: 'Mengerti / paham',
            kalimatKasual: 'わかった！(Wakatta!)',
            kalimatSopan: 'わかりました。(Wakarimashita.)',
            konteks:
                'Dipakai saat memahami instruksi atau penjelasan—gunakan bentuk sopan saat bicara dengan atasan/guru.',
          ),
        ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _resetCardPosition();
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetCardPosition();
      });
    }
  }

  void _shuffleCards() {
    setState(() {
      _cards.shuffle();
      _currentIndex = 0;
      _resetCardPosition();
    });
  }

  void _resetCardPosition() {
    _isFront = true;
    _controller.reset();
  }

  void _openQuickQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuickQuizScreen(
          cards: _cards,
          isSoftDark: _isSoftDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isSoftDark ? _darkBg : _lightBg;
    final surfaceColor = _isSoftDark ? _darkSurface : _lightSurface;
    final textColor = _isSoftDark ? _darkText : _lightText;
    final mutedText = _isSoftDark ? const Color(0xFFB3ACA0) : const Color(0xFF6B655E);

    final currentCard = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(
          widget.kategori,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSoftDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            tooltip: _isSoftDark ? 'Mode Terang Lembut' : 'Mode Gelap Lembut',
            onPressed: () => setState(() => _isSoftDark = !_isSoftDark),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Acak Kartu',
            onPressed: _shuffleCards,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Tombol Kuis Kilat 1-2 Menit
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openQuickQuiz,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Kuis Kilat (5 Soal • ~1 Menit)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: BorderSide(color: _accent.withOpacity(0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Indikator Progres
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kartu ${_currentIndex + 1} / ${_cards.length}',
                    style: TextStyle(color: mutedText, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(color: mutedText, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: surfaceColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
              const SizedBox(height: 20),

              // Kartu Interaktif (Tap untuk balik)
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value * pi;
                      final isBack = angle >= (pi / 2);

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildBackCard(
                                  currentCard,
                                  surfaceColor,
                                  textColor,
                                  mutedText,
                                ),
                              )
                            : _buildFrontCard(
                                currentCard,
                                surfaceColor,
                                textColor,
                                mutedText,
                              ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Ketuk kartu untuk melihat contoh kasual, sopan & konteks',
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedText, fontSize: 12.5),
              ),
              const SizedBox(height: 16),

              // Navigasi Kartu
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentIndex > 0 ? _prevCard : null,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Sebelumnya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: surfaceColor,
                        foregroundColor: textColor,
                        disabledBackgroundColor: surfaceColor.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _currentIndex < _cards.length - 1 ? _nextCard : null,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Selanjutnya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _accent.withOpacity(0.35),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(
    FlashcardItem item,
    Color surfaceColor,
    Color textColor,
    Color mutedText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: textColor.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'KOSAKATA',
              style: TextStyle(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            item.kanjiOrKana,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.romaji,
            style: TextStyle(
              fontSize: 18,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(
    FlashcardItem item,
    Color surfaceColor,
    Color textColor,
    Color mutedText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.35)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.kanjiOrKana} (${item.romaji})',
              style: TextStyle(color: mutedText, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              item.arti,
              style: TextStyle(
                color: textColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

          // Bentuk Kasual
          if (item.kalimatKasual != null) ...[
            _buildStyleBox(
              label: 'Kasual (Sehari-hari / Teman)',
              text: item.kalimatKasual!,
              bg: _isSoftDark ? const Color(0xFF1C1B1A) : const Color(0xFFF7F5F0),
              textColor: textColor,
              badgeColor: const Color(0xFF6B9AC4),
            ),
            const SizedBox(height: 10),
          ],

          // Bentuk Sopan (Desu/Masu)
          if (item.kalimatSopan != null) ...[
            _buildStyleBox(
              label: 'Sopan (-masu / -desu)',
              text: item.kalimatSopan!,
              bg: _isSoftDark ? const Color(0xFF1C1B1A) : const Color(0xFFF7F5F0),
              textColor: textColor,
              badgeColor: const Color(0xFF7AA874),
            ),
            const SizedBox(height: 14),
          ],

          // Konteks Pemakaian
          if (item.konteks != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: _accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.konteks!,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleBox({
    required String label,
    required String text,
    required Color bg,
    required Color textColor,
    required Color badgeColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// KUIS KILAT 1-2 MENIT (5 SOAL)
// ============================================================================

class QuickQuizScreen extends StatefulWidget {
  final List<FlashcardItem> cards;
  final bool isSoftDark;

  const QuickQuizScreen({
    Key? key,
    required this.cards,
    required this.isSoftDark,
  }) : super(key: key);

  @override
  State<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends State<QuickQuizScreen> {
  late List<FlashcardItem> _questions;
  late List<List<String>> _optionsPerQuestion;
  int _qIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _setupQuiz();
  }

  void _setupQuiz() {
    final pool = List<FlashcardItem>.from(widget.cards)..shuffle();
    final totalQuestions = min(5, pool.length);
    _questions = pool.take(totalQuestions).toList();

    _optionsPerQuestion = _questions.map((target) {
      final distractors = widget.cards
          .where((c) => c.arti != target.arti)
          .map((c) => c.arti)
          .toList()
        ..shuffle();

      final choices = <String>[target.arti, ...distractors.take(3)]..shuffle();
      return choices;
    }).toList();

    _qIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isFinished = false;
  }

  void _answerQuestion(String option, String correctAnswer) {
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = option;
      if (option == correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_qIndex < _questions.length - 1) {
      setState(() {
        _qIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSoftDark ? const Color(0xFF1C1B1A) : const Color(0xFFF7F5F0);
    final surfaceColor = widget.isSoftDark ? const Color(0xFF282624) : const Color(0xFFECE8DF);
    final textColor = widget.isSoftDark ? const Color(0xFFEAE5DC) : const Color(0xFF262422);
    const accent = Color(0xFFD97757);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text('Kuis Kilat (5 Soal)'),
      ),
      body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
          child: _isFinished
              ? _buildResultView(surfaceColor, textColor, accent)
              : _buildQuestionView(surfaceColor, textColor, accent),
         ),
      ),
    );
  }

  Widget _buildQuestionView(Color surfaceColor, Color textColor, Color accent) {
    final q = _questions[_qIndex];
    final options = _optionsPerQuestion[_qIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Soal ${_qIndex + 1} dari ${_questions.length}',
          style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'Apa arti dari kata ini?',
                style: TextStyle(color: textColor.withOpacity(0.75), fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                q.kanjiOrKana,
                style: TextStyle(color: textColor, fontSize: 38, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                q.romaji,
                style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...options.map((opt) {
          final isPicked = _selectedAnswer == opt;
          final isCorrect = opt == q.arti;

          Color btnBg = surfaceColor;
          if (_selectedAnswer != null) {
            if (isCorrect) {
              btnBg = const Color(0xFF3E6B48); // Hijau lembut
            } else if (isPicked) {
              btnBg = const Color(0xFF8C3B3B); // Merah lembut
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () => _answerQuestion(opt, q.arti),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: _selectedAnswer != null && (isCorrect || isPicked)
                    ? Colors.white
                    : textColor,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(opt, style: const TextStyle(fontSize: 15)),
            ),
          );
        }),

        const Spacer(),
        if (_selectedAnswer != null)
          ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _qIndex < _questions.length - 1 ? 'Soal Berikutnya' : 'Lihat Hasil',
            ),
          ),
      ],
    );
  }

  Widget _buildResultView(Color surfaceColor, Color textColor, Color accent) {
    final total = _questions.length;
    final pesan = _score >= 4
        ? 'Mantap! Ingatanmu lagi tajam banget.'
        : _score >= 2
            ? 'Lumayan santai, ulangi sekali lagi pasti makin nempel!'
            : 'Santai saja, balik ke kartu lalu coba kuisnya lagi.';

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration_outlined, size: 48, color: accent),
            const SizedBox(height: 12),
            Text(
              'Kuis Kilat Selesai!',
              style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor kamu: $_score / $total',
              style: TextStyle(color: accent, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(_setupQuiz),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Main Lagi (5 Soal Baru)'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kembali ke Flashcard', style: TextStyle(color: textColor)),
            ),
          ],
        ),
      ),
    );
  }
}
