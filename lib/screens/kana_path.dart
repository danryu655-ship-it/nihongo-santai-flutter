import 'dart:math';

import 'package:flutter/material.dart';

import '../data/kana.dart';
import '../services/store.dart';
import '../services/tts_service.dart';
import '../widgets.dart';

/// Jalur belajar kana ala Duolingo: simpul-simpul huruf yang berliku,
/// terbuka satu demi satu. Simpul hijau = dikuasai, putih = terbuka,
/// abu-abu bergembok = terkunci. Ketuk simpul terbuka untuk latihan singkat.
class KanaPath extends StatelessWidget {
  const KanaPath({super.key, required this.state, required this.hiragana});

  final AppState state;

  /// true = jalur Hiragana, false = jalur Katakana.
  final bool hiragana;

  /// Bab per baris kana: (nama, indeks awal, jumlah huruf).
  static const List<(String, int, int)> _bab = [
    ('Vokal', 0, 5),
    ('K', 5, 5),
    ('S', 10, 5),
    ('T', 15, 5),
    ('N', 20, 5),
    ('H', 25, 5),
    ('M', 30, 5),
    ('Y', 35, 3),
    ('R', 38, 5),
    ('W', 43, 3),
  ];

  List<KanaChar> get _chars => hiragana ? kanaBasicHiragana : kanaBasicKatakana;

  @override
  Widget build(BuildContext context) {
    final chars = _chars;
    final mastered =
        chars.where((c) => state.kanaMastery(c.kana) >= 1).length;
    final dark = state.softDark;
    // Dekorasi pemandangan di sela-sela bab (setelah BAB 2, 5, 8).
    const decorations = {1: '🌸', 4: '🏯', 7: '🗻'};
    return Stack(
      children: [
        // Latar gradien hijau muda ala gambar contoh (gelap bila tema gelap).
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? const [Color(0xFF1C2B20), Color(0xFF10160F)]
                    : const [Color(0xFFDDEED3), Color(0xFFF4F9EA)],
              ),
            ),
          ),
        ),
        // Gelembung awan lembut di latar.
        Positioned(top: 90, right: -40, child: _blob(150, dark)),
        Positioned(top: 430, left: -50, child: _blob(130, dark)),
        Positioned(bottom: 140, right: -30, child: _blob(110, dark)),
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              hiragana ? 'Jalur Hiragana' : 'Jalur Katakana',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$mastered dari ${chars.length} huruf dikuasai',
              style: const TextStyle(
                  fontSize: 13, color: brand, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: chars.isEmpty ? 0 : mastered / chars.length,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(okGreen),
              ),
            ),
            // Gerbang torii di atas jalur.
            const _SceneRow(center: '⛩️'),
            for (var b = 0; b < _bab.length; b++) ...[
              _BabHeader(
                index: b + 1,
                name: _bab[b].$1,
                chars: chars.sublist(_bab[b].$2, _bab[b].$2 + _bab[b].$3),
                state: state,
              ),
              for (var j = 0; j < _bab[b].$3; j++)
                _NodeRow(
                  chars: chars,
                  globalIndex: _bab[b].$2 + j,
                  inBabIndex: j,
                  babSize: _bab[b].$3,
                  state: state,
                ),
              if (decorations.containsKey(b))
                _SceneRow(center: decorations[b]!),
            ],
            // Bukit di ujung jalur.
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(painter: _HillsPainter(dark: dark)),
            ),
            const SizedBox(height: 8),
            const Text(
              'がんばって！ Terus semangat!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  /// Gelembung putih lembut untuk latar.
  Widget _blob(double size, bool dark) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: dark ? 0.04 : 0.35),
        ),
      );
}

/// Satu baris dekorasi pemandangan (mis. torii diapit awan).
class _SceneRow extends StatelessWidget {
  const _SceneRow({required this.center, this.sides = '☁️'});

  final String center;
  final String sides;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(sides, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Text(center, style: const TextStyle(fontSize: 56)),
          const SizedBox(width: 12),
          Text(sides, style: const TextStyle(fontSize: 26)),
        ],
      ),
    );
  }
}

/// Dua bukit hijau bergelombang di ujung jalur.
class _HillsPainter extends CustomPainter {
  const _HillsPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final back = Paint()
      ..color = dark ? const Color(0xFF2A4A32) : const Color(0xFFBFDDB0);
    final front = Paint()
      ..color = dark ? const Color(0xFF1E3325) : const Color(0xFFA8D194);
    final p1 = Path()..moveTo(0, size.height * 0.55);
    p1.quadraticBezierTo(size.width * 0.25, size.height * 0.2,
        size.width * 0.5, size.height * 0.55);
    p1.quadraticBezierTo(size.width * 0.75, size.height * 0.9,
        size.width, size.height * 0.5);
    p1.lineTo(size.width, size.height);
    p1.lineTo(0, size.height);
    p1.close();
    canvas.drawPath(p1, back);
    final p2 = Path()..moveTo(0, size.height * 0.75);
    p2.quadraticBezierTo(size.width * 0.3, size.height * 0.45,
        size.width * 0.6, size.height * 0.75);
    p2.quadraticBezierTo(size.width * 0.85, size.height * 0.95,
        size.width, size.height * 0.7);
    p2.lineTo(size.width, size.height);
    p2.lineTo(0, size.height);
    p2.close();
    canvas.drawPath(p2, front);
  }

  @override
  bool shouldRepaint(_HillsPainter old) => old.dark != dark;
}

/// Header tiap bab: pil "BAB n • Baris X" + progres bab.
class _BabHeader extends StatelessWidget {
  const _BabHeader({
    required this.index,
    required this.name,
    required this.chars,
    required this.state,
  });

  final int index;
  final String name;
  final List<KanaChar> chars;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final done = chars.where((c) => state.kanaMastery(c.kana) >= 1).length;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: brand,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'BAB $index • Baris $name',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$done/${chars.length}',
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Satu baris simpul: garis kuning berliku (CustomPaint) + lingkaran simpul.
class _NodeRow extends StatelessWidget {
  const _NodeRow({
    required this.chars,
    required this.globalIndex,
    required this.inBabIndex,
    required this.babSize,
    required this.state,
  });

  final List<KanaChar> chars;
  final int globalIndex;
  final int inBabIndex;
  final int babSize;
  final AppState state;

  static const double _rowHeight = 84;
  static const double _nodeSize = 64;

  /// Posisi horizontal simpul: berliku seperti sinus di sekitar tengah.
  double _offsetX(int i) => sin(i * 0.9) * 64;

  @override
  Widget build(BuildContext context) {
    final c = chars[globalIndex];
    final mastery = state.kanaMastery(c.kana);
    final unlocked = globalIndex == 0 ||
        state.kanaMastery(chars[globalIndex - 1].kana) >= 1;
    final done = mastery >= 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cx = w / 2;
        final thisX = cx + _offsetX(globalIndex);
        final prevX = inBabIndex == 0
            ? null
            : cx + _offsetX(globalIndex - 1);
        final nextX = inBabIndex == babSize - 1
            ? null
            : cx + _offsetX(globalIndex + 1);
        return SizedBox(
          height: _rowHeight,
          width: double.infinity,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(double.infinity, _rowHeight),
                painter: _ConnectorPainter(
                  prevX: prevX,
                  thisX: thisX,
                  nextX: nextX,
                  rowHeight: _rowHeight,
                ),
              ),
              Positioned(
                left: thisX - _nodeSize / 2,
                top: (_rowHeight - _nodeSize) / 2,
                child: _NodeCircle(
                  c: c,
                  mastery: mastery,
                  unlocked: unlocked,
                  done: done,
                  onTap: () {
                    if (!unlocked) {
                      showMsg(context,
                          'Selesaikan simpul sebelumnya dulu untuk membuka ${c.kana}.');
                      return;
                    }
                    final babStart =
                        globalIndex - inBabIndex;
                    final babChars = chars.sublist(
                        babStart, babStart + babSize);
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _NodePracticeSheet(
                        state: state,
                        target: c,
                        babChars: babChars,
                        allChars: chars,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Garis kuning berliku yang menghubungkan simpul sebelumnya,
/// simpul ini, dan simpul berikutnya.
class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.prevX,
    required this.thisX,
    required this.nextX,
    required this.rowHeight,
  });

  final double? prevX;
  final double thisX;
  final double? nextX;
  final double rowHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5B841)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mid = rowHeight / 2;
    final path = Path();
    if (prevX != null) {
      path.moveTo(prevX!, -mid - 6);
      path.cubicTo(prevX!, 0, thisX, 0, thisX, mid);
    } else {
      path.moveTo(thisX, mid);
    }
    if (nextX != null) {
      path.cubicTo(thisX, rowHeight, nextX!, rowHeight, nextX!,
          rowHeight + mid + 6);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.prevX != prevX || old.thisX != thisX || old.nextX != nextX;
}

/// Lingkaran simpul: hijau + centang bila dikuasai, putih berbingkai bila
/// terbuka (cincin menunjukkan progres), abu-abu bergembok bila terkunci.
class _NodeCircle extends StatelessWidget {
  const _NodeCircle({
    required this.c,
    required this.mastery,
    required this.unlocked,
    required this.done,
    required this.onTap,
  });

  final KanaChar c;
  final double mastery;
  final bool unlocked;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: done
            ? okGreen
            : unlocked
                ? Colors.white
                : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: Border.all(
          color: done
              ? okGreen
              : unlocked
                  ? brand
                  : Colors.grey.shade400,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 30)
            : unlocked
                ? Text(
                    c.kana,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  )
                : Icon(Icons.lock,
                    color: Colors.grey.shade600, size: 26),
      ),
    );
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: unlocked && !done
          ? SizedBox(
              width: size + 8,
              height: size + 8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: size + 8,
                    height: size + 8,
                    child: CircularProgressIndicator(
                      value: mastery.clamp(0, 1).toDouble(),
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(brand),
                    ),
                  ),
                  circle,
                ],
              ),
            )
          : circle,
    );
  }
}

/// Latihan singkat simpul: 3 soal kana -> romaji dari baris yang sama.
/// Tiap jawaban memanggil bumpKana (+0,25 bila benar, -0,1 bila salah).
class _NodePracticeSheet extends StatefulWidget {
  const _NodePracticeSheet({
    required this.state,
    required this.target,
    required this.babChars,
    required this.allChars,
  });

  final AppState state;
  final KanaChar target;
  final List<KanaChar> babChars;
  final List<KanaChar> allChars;

  @override
  State<_NodePracticeSheet> createState() => _NodePracticeSheetState();
}

class _NodePracticeSheetState extends State<_NodePracticeSheet> {
  late final List<KanaChar> _questions;
  late final List<List<String>> _options;
  int _qi = 0;
  int _correct = 0;
  String? _picked;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    final pool = [...widget.babChars]..shuffle(rnd);
    // Target selalu jadi soal pertama.
    pool.remove(widget.target);
    _questions = [widget.target, ...pool.take(2)];
    final uniqueRomaji = <String>{};
    for (final c in widget.allChars) {
      uniqueRomaji.add(c.romaji);
    }
    _options = _questions.map((q) {
      final distract = uniqueRomaji.where((r) => r != q.romaji).toList()
        ..shuffle(rnd);
      return ([q.romaji, ...distract.take(3)]..shuffle(rnd));
    }).toList();
  }

  void _answer(String romaji) {
    if (_picked != null) return;
    final q = _questions[_qi];
    final ok = romaji == q.romaji;
    widget.state.bumpKana(q.kana, ok);
    setState(() {
      _picked = romaji;
      if (ok) _correct++;
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        if (_qi + 1 >= _questions.length) {
          _finished = true;
        } else {
          _qi++;
          _picked = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.state.softDark;
    final bg = dark ? const Color(0xFF282624) : Colors.white;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_finished) ...[
                const Icon(Icons.celebration,
                    color: okGreen, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Selesai! $_correct dari ${_questions.length} benar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Penguasaan ${widget.target.kana}: '
                  '${(widget.state.kanaMastery(widget.target.kana) * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'TUTUP',
                  icon: Icons.check,
                  onPressed: () => Navigator.pop(context),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.target.kana,
                      style: const TextStyle(
                          fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up,
                          color: brand, size: 30),
                      onPressed: () =>
                          TtsService.instance.speak(widget.target.kana),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Soal ${_qi + 1} dari ${_questions.length}: '
                  'apa romaji dari ${_questions[_qi].kana}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                for (final opt in _options[_qi])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _answer(opt),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _picked == null
                              ? (dark
                                  ? const Color(0xFF3A3733)
                                  : Colors.grey.shade100)
                              : opt == _questions[_qi].romaji
                                  ? okGreen.withValues(alpha: 0.15)
                                  : opt == _picked
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : (dark
                                          ? const Color(0xFF3A3733)
                                          : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _picked != null &&
                                    opt == _questions[_qi].romaji
                                ? okGreen
                                : _picked == opt
                                    ? Colors.red
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          opt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Hiragana dasar (46 huruf) — data kana sudah memisahkan dakuten.
List<KanaChar> get kanaBasicHiragana => hiragana;

/// Katakana dasar (46 huruf) — data kana sudah memisahkan dakuten.
List<KanaChar> get kanaBasicKatakana => katakana;
