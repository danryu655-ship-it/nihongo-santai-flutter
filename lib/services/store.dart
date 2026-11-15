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

  // ---------- Trip ----------
  String tripCity = 'Tokyo|東京';
  int tripDays = 3;
  int tripBudget = 100000;
  String tripNote = '';
  List<Map<String, dynamic>> itin = []; // {day, time, activity}
  Map<String, String> flight = {}; // airline, number, date, depTime, arrTime, from, to
  List<Map<String, dynamic>> docs = []; // {type, code, note}
  List<int> packDone = []; // indeks packingList
  List<String> wishes = [];
  List<Map<String, dynamic>> expenses = []; // {name, amt}
  int splitPeople = 2;

  int get level => xp ~/ 100 + 1;
  int get xpIntoLevel => xp % 100;
  int get lessonsDone => done.length;

  String get tripCityName => tripCity.split('|').first;
  String get tripCityJapanese =>
      tripCity.contains('|') ? tripCity.split('|').last : '';

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

    final trip = _json('nsf_trip_v1');
    tripCity = trip['city'] as String? ?? 'Tokyo|東京';
    tripDays = (trip['days'] as num?)?.toInt() ?? 3;
    tripBudget = (trip['budget'] as num?)?.toInt() ?? 100000;
    tripNote = trip['note'] as String? ?? '';

    itin = _mapList('nsf_itin_v1');
    final fl = _json('nsf_flight_v1');
    flight = fl.map((k, v) => MapEntry(k.toString(), v.toString()));
    docs = _mapList('nsf_docs_v1');
    packDone = _intList('nsf_pack_v1');
    wishes = _strList('nsf_wish_v1');
    expenses = _mapList('nsf_exp_v1');
    splitPeople = _prefs.getInt('nsf_split_v1') ?? 2;
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

  List<Map<String, dynamic>> _mapList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final v = jsonDecode(raw);
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
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

  // ---------- Trip ----------
  void saveTrip({
    required String city,
    required int days,
    required int budget,
    required String note,
  }) {
    tripCity = city;
    tripDays = days;
    tripBudget = budget;
    tripNote = note;
    _save(
      'nsf_trip_v1',
      jsonEncode({
        'city': city,
        'days': days,
        'budget': budget,
        'note': note,
      }),
    );
    notifyListeners();
  }

  void addItin(int day, String time, String activity) {
    itin.add({'day': day, 'time': time, 'activity': activity});
    _save('nsf_itin_v1', jsonEncode(itin));
    notifyListeners();
  }

  void delItin(int index) {
    itin.removeAt(index);
    _save('nsf_itin_v1', jsonEncode(itin));
    notifyListeners();
  }

  void applyTemplate(List<Map<String, dynamic>> items) {
    itin.addAll(items);
    _save('nsf_itin_v1', jsonEncode(itin));
    notifyListeners();
  }

  void saveFlight(Map<String, String> f) {
    flight = Map.of(f);
    _save('nsf_flight_v1', jsonEncode(flight));
    notifyListeners();
  }

  void clearFlight() {
    flight = {};
    _save('nsf_flight_v1', jsonEncode(flight));
    notifyListeners();
  }

  void addDoc(String type, String code, String note) {
    docs.add({'type': type, 'code': code, 'note': note});
    _save('nsf_docs_v1', jsonEncode(docs));
    notifyListeners();
  }

  void delDoc(int index) {
    docs.removeAt(index);
    _save('nsf_docs_v1', jsonEncode(docs));
    notifyListeners();
  }

  void togglePack(int i) {
    if (packDone.contains(i)) {
      packDone.remove(i);
    } else {
      packDone.add(i);
    }
    _save('nsf_pack_v1', jsonEncode(packDone));
    notifyListeners();
  }

  void addWish(String w) {
    wishes.add(w);
    _save('nsf_wish_v1', jsonEncode(wishes));
    notifyListeners();
  }

  void delWish(int index) {
    wishes.removeAt(index);
    _save('nsf_wish_v1', jsonEncode(wishes));
    notifyListeners();
  }

  void addExpense(String name, int amt) {
    expenses.add({'name': name, 'amt': amt});
    _save('nsf_exp_v1', jsonEncode(expenses));
    notifyListeners();
  }

  void delExpense(int index) {
    expenses.removeAt(index);
    _save('nsf_exp_v1', jsonEncode(expenses));
    notifyListeners();
  }

  int get totalExpense =>
      expenses.fold(0, (s, e) => s + ((e['amt'] as num?)?.toInt() ?? 0));

  void setSplitPeople(int n) {
    splitPeople = n.clamp(1, 50);
    _save('nsf_split_v1', splitPeople);
    notifyListeners();
  }
}
