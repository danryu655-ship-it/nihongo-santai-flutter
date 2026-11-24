import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/kana_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/phrases_screen.dart';
import 'screens/translate_screen.dart';
import 'services/store.dart';
import 'services/school_sync.dart';
import 'widgets.dart';
import 'services/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final startedAt = DateTime.now();
  final state = await AppState.load();
  // Kirim antrean progres yang tertunda saat offline kemarin.
  // Tanpa await: tidak menghambat aplikasi dibuka.
  SchoolSyncService.instance.flushPending(state);
  runApp(NihongoApp(state: state, startedAt: startedAt));
}

class NihongoApp extends StatelessWidget {
  const NihongoApp({super.key, required this.state, required this.startedAt});

  final AppState state;

  /// Waktu aplikasi mulai dibuka (untuk menghitung durasi splash 30 detik).
  final DateTime startedAt;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Nihongo Santai',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(state.softDark),
          home: HomePage(state: state, startedAt: startedAt),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.state, required this.startedAt});

  final AppState state;
  final DateTime startedAt;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  bool _showSplash = true;
  Timer? _splashTimer;

  /// Splash tampil total 30 detik sejak aplikasi dibuka (termasuk waktu
  /// native splash), bisa di-skip dengan ketukan.
  static const _splashTotal = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    final elapsed = DateTime.now().difference(widget.startedAt);
    final remaining = _splashTotal - elapsed;
    if (remaining <= Duration.zero) {
      _showSplash = false;
    } else {
      _splashTimer = Timer(remaining, () {
        if (mounted) setState(() => _showSplash = false);
      });
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  void _skipSplash() {
    _splashTimer?.cancel();
    if (_showSplash) setState(() => _showSplash = false);
  }

  @override
Widget build(BuildContext context) {
  if (_showSplash) return _buildSplash();
  // Tab Sekolah dihapus 16 Nov 2026 (v1.0.0+24): HP user tidak bisa
  // mencapai Supabase maupun relay Google — tab hanya menampilkan error.
  // Sinkronisasi progres tetap jalan diam-diam di latar (tanpa error
  // di layar), jadi bila jaringan HP membaik datanya tetap tersimpan.
  final pages = <Widget>[
      LearnScreen(state: widget.state),
      PhrasesScreen(state: widget.state),
      TranslateScreen(state: widget.state),
      KanaScreen(state: widget.state),
    ];
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 96),
                child: pages[_tab],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFloatingNav(),
    );
  }

  /// Navbar mengambang ala Goukaku: pil bulat dengan bayangan,
  /// tab aktif berpil gelap. Melayang di atas konten (extendBody).
  Widget _buildFloatingNav() {
    final dark = widget.state.softDark;
    final bg = dark ? const Color(0xFF282624) : Colors.white;
    final idle = dark ? Colors.grey.shade400 : Colors.grey.shade600;
    const activeBg = Color(0xFF3D5A73);
    const labels = ['Belajar', 'Frasa', 'Terjemah', 'Kana'];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tab = i),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _tab == i ? activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (i == 3)
                          Text('あ',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _tab == i ? Colors.white : idle))
                        else
                          Icon(
                            i == 0
                                ? Icons.school
                                : i == 1
                                    ? Icons.chat_bubble_outline
                                    : Icons.translate,
                            color: _tab == i ? Colors.white : idle,
                          ),
                        const SizedBox(height: 2),
                        Text(labels[i],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _tab == i ? Colors.white : idle)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Layar splash Flutter: logo besar + judul + subtitle di atas latar
  /// ungu brand. Muncul setelah native splash hilang, total 30 detik
  /// sejak aplikasi dibuka. Ketuk di mana saja untuk lanjut lebih cepat.
  Widget _buildSplash() {
    return GestureDetector(
      onTap: _skipSplash,
      child: Scaffold(
        backgroundColor: brand,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      child: Text('日',
                          style: TextStyle(fontSize: 80, color: brand)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Nihongo Santai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Translate, Belajar & Kana',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                const Text(
                  'Ketuk untuk lanjut',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final s = widget.state;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            color: brand,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text('日',
                            style: TextStyle(
                                fontSize: 24, color: brand)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nihongo Santai',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Translate, Belajar & Kana',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      s.softDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: Colors.white,
                    ),
                    tooltip: s.softDark ? 'Mode Terang Lembut' : 'Mode Gelap Lembut',
                    onPressed: () => s.setSoftDark(!s.softDark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _stat('⭐ ${s.xp}', 'XP'),
                  _stat('🎖️ Lv ${s.level}', 'Level ${s.xpIntoLevel}/100'),
                  _stat('🔥 ${s.streak}', 'Streak hari'),
                  _stat('📚 ${s.lessonsDone}/48', 'Pelajaran'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String big, String small) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              big,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              small,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
