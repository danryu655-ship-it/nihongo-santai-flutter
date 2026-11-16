import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Semua penyimpanan aplikasi memakai prefix `nsf_`.
/// Data versi WebView lama (tbo_*/nst_*) TIDAK bisa pindah — Flutter mulai dari nol.
class AppState extends ChangeNotifier {
  AppState._(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = AppState._(prefs);
    s._loadAll();
    return s;
  }

  // ---------- Progress belajar ----------
  int xp = 0;
  int streak = 0;
  String lastDay = ''; // format yyyy-m-d
  Map<String, int> done = {}; // lessonId -> skor (10)

  // ---------- Kamus / terjemah ----------
  List<String> favs = []; // kunci japanese
  List<String> recents = []; // kunci japanese, maks 8
  bool forceOffline = false;

  // ---------- Belajar ----------
  List<int> konbiniDone = []; // indeks konbiniItems
  int quizBest = 0;

  // ---------- Identitas siswa (Sekolah) ----------
  String? studentKey; // kunci siswa ('cecilia' | 'ferdi' | 'villia' | 'yusrizal'), null = belum pilih
  bool schoolPending = false; // true = ada progres yang gagal terkirim

  // ---------- Kana ----------
  Map<String, double> kanaProgress = {}; // huruf kana -> penguasaan 0..1

  int get level => xp ~/ 100 + 1;
  int get xpIntoLevel => xp % 100;
  int get lessonsDone => done.length;

  // ---------- Load ----------
  void _loadAll() {
    final prog = _json('nsf_prog_v1');
    xp = (prog['xp'] as num?)?.toInt() ?? 0;
    streak = (prog['streak'] as num?)?.toInt() ?? 0;
    lastDay = prog['lastDay'] as String? ?? '';
    final d = prog['done'];
    if (d is Map) {
      done = d.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
    favs = _strList('nsf_fav');
    recents = _strList('nsf_recent');
    forceOffline = _prefs.getBool('nsf_force_offline') ?? false;
    konbiniDone = _intList('nsf_konbini_v1');
    quizBest = _prefs.getInt('nsf_quiz_best_v1') ?? 0;

    studentKey = _prefs.getString('nsf_student_key');
    schoolPending = _prefs.getBool('nsf_school_pending') ?? false;

    final kp = _json('nsf_kana_progress');
    kanaProgress = kp.map(
      (k, v) =>
          MapEntry(k.toString(), (v as num).toDouble().clamp(0, 1).toDouble()),
    );
  }

  Map<String, dynamic> _json(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final v = jsonDecode(raw);
      return v is Map<String, dynamic> ? v : {};
    } catch (_) {
      return {};
    }
  }

  List<String> _strList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final v = jsonDecode(raw);
      return v is List ? v.map((e) => e.toString()).toList() : [];
    } catch (_) {
      return [];
    }
  }

  List<int> _intList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final v = jsonDecode(raw);
      return v is List
          ? v.map((e) => (e as num).toInt()).toList()
          : [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(String key, Object value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    }
  }

  void _saveProg() {
    _save(
      'nsf_prog_v1',
      jsonEncode({
        'xp': xp,
        'streak': streak,
        'lastDay': lastDay,
        'done': done,
      }),
    );
  }

  // ---------- Progress ----------
  void addXp(int n) {
    xp += n;
    _saveProg();
    notifyListeners();
  }

  void completeLesson(String lessonId) {
    done[lessonId] = 10;
    _bumpStreak();
    _saveProg();
    notifyListeners();
  }

  void _bumpStreak() {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    if (lastDay == today) return;
    final y = now.subtract(const Duration(days: 1));
    final ys = '${y.year}-${y.month}-${y.day}';
    streak = (lastDay == ys) ? streak + 1 : 1;
    lastDay = today;
  }

  // ---------- Kamus ----------
  bool isFav(String japanese) => favs.contains(japanese);

  void toggleFav(String japanese) {
    if (favs.contains(japanese)) {
      favs.remove(japanese);
    } else {
      favs.add(japanese);
    }
    _save('nsf_fav', jsonEncode(favs));
    notifyListeners();
  }

  void addRecent(String japanese) {
    recents = [japanese, ...recents.where((x) => x != japanese)].take(8).toList();
    _save('nsf_recent', jsonEncode(recents));
    notifyListeners();
  }

  void setForceOffline(bool v) {
    forceOffline = v;
    _save('nsf_force_offline', v);
    notifyListeners();
  }

  // ---------- Konbini / kuis ----------
  void toggleKonbini(int i) {
    if (konbiniDone.contains(i)) {
      konbiniDone.remove(i);
    } else {
      konbiniDone.add(i);
    }
    _save('nsf_konbini_v1', jsonEncode(konbiniDone));
    notifyListeners();
  }

  void setQuizBest(int score) {
    if (score > quizBest) {
      quizBest = score;
      _save('nsf_quiz_best_v1', score);
      notifyListeners();
    }
  }

  // ---------- Kana ----------
  double kanaMastery(String kana) => kanaProgress[kana] ?? 0;

    // ---------- Identitas siswa (Sekolah) ----------
  void setStudentKey(String key) {
    studentKey = key;
    _save('nsf_student_key', key);
    notifyListeners();
  }

  void markSchoolPending() {
    if (!schoolPending) {
      schoolPending = true;
      _save('nsf_school_pending', true);
    }
  }

  void clearSchoolPending() {
    if (schoolPending) {
      schoolPending = false;
      _save('nsf_school_pending', false);
    }
  }

  /// Jawaban kuis benar: penguasaan huruf naik +0.25 (maks 1).
  /// Jawaban salah: turun -0.1 (min 0).
  void bumpKana(String kana, bool correct) {
    final cur = kanaProgress[kana] ?? 0;
    final next = correct
        ? (cur + 0.25).clamp(0, 1).toDouble()
        : (cur - 0.1).clamp(0, 1).toDouble();
    kanaProgress[kana] = next;
    _save('nsf_kana_progress', jsonEncode(kanaProgress));
    notifyListeners();
  }
}
