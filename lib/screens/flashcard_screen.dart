import 'dart:math';
import 'package:flutter/material.dart';

// Model sederhana untuk data Flashcard (Bisa disesuaikan dengan model kosakata yang sudah ada di repo kamu)
class FlashcardItem {
  final String kanjiOrKana;
  final String romaji;
  final String arti;
  final String contohKalimat;

  FlashcardItem({
    required this.kanjiOrKana,
    required this.romaji,
    required this.arti,
    this.contohKalimat = '',
  });
}

class FlashcardScreen extends StatefulWidget {
  final String kategori;
  final List<FlashcardItem>? customCards;

  const FlashcardScreen({
    Key? key,
    this.kategori = 'Kosakata Dasar',
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
  int _currentIndex = 0;

  // Data dummy jika tidak ada data yang dikirim dari halaman sebelumnya
  late List<FlashcardItem> _cards;

  @override
  void initState() {
    super.initState();
    _cards = widget.customCards ??
        [
          FlashcardItem(
            kanjiOrKana: 'ありがとう',
            romaji: 'Arigatou',
            arti: 'Terima kasih',
            contohKalimat: 'いつもありがとう。(Terima kasih untuk selalu membantu.)',
          ),
          FlashcardItem(
            kanjiOrKana: '食べる',
            romaji: 'Taberu',
            arti: 'Makan',
            contohKalimat: '朝ごはんを食べる。(Makan sarapan.)',
          ),
          FlashcardItem(
            kanjiOrKana: '猫',
            romaji: 'Neko',
            arti: 'Kucing',
            contohKalimat: '猫が好きです。(Saya suka kucing.)',
          ),
          FlashcardItem(
            kanjiOrKana: '大丈夫',
            romaji: 'Daijoubu',
            arti: 'Tidak apa-apa / Baik-baik saja',
            contohKalimat: '大丈夫ですか？(Apakah kamu baik-baik saja?)',
          ),
        ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard: ${widget.kategori}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Acak Kartu',
            onPressed: _shuffleCards,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Indikator Progres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kartu ${_currentIndex + 1} dari ${_cards.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${(progress * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
            const Spacer(),

            // Area Kartu (Bisa di-tap untuk flip)
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  final isBack = angle >= (pi / 2);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Efek perspektif 3D
                      ..rotateY(angle),
                    child: isBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildBackCard(currentCard),
                          )
                        : _buildFrontCard(currentCard),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Ketuk kartu untuk membalik',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Spacer(),

            // Tombol Navigasi Bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0 ? _prevCard : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Sebelumnya'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _currentIndex < _cards.length - 1 ? _nextCard : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Selanjutnya'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Tampilan Depan Kartu (Huruf Jepang)
  Widget _buildFrontCard(FlashcardItem item) {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            item.kanjiOrKana,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  // Tampilan Belakang Kartu (Romaji, Arti, & Contoh)
  Widget _buildBackCard(FlashcardItem item) {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.romaji,
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.arti,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            if (item.contohKalimat.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                item.contohKalimat,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
