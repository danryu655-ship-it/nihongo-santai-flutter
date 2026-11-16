import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../data/lessons.dart';
import 'store.dart';

/// Satu baris daftar siswa dari Supabase (untuk tab Sekolah di aplikasi).
class SchoolStudent {
  const SchoolStudent({
    required this.key,
    required this.name,
    required this.level,
    required this.lessonsDone,
    required this.xp,
  });

  final String key;
  final String name;
  final String level;
  final int lessonsDone;
  final int xp;
}

/// Sinkronisasi progres belajar ke Supabase (tabel public.school_progress)
/// untuk dibaca Sekolah Nihongo Santai (versi live).
///
/// Pakai PostgREST langsung lewat package `http` (sudah ada di pubspec
/// versi ^1.4.0, dipakai juga oleh translate_service.dart) — tanpa package
/// tambahan, tanpa supabase_flutter.
///
/// TIDAK PERNAH melempar exception: semua kegagalan ditangkap dan hanya
/// menandai antrean tertunda. Aplikasi tetap jalan normal walau offline
/// atau Supabase tidak terjangkau.
class SchoolSyncService {
  SchoolSyncService._();

  static final SchoolSyncService instance = SchoolSyncService._();

  static const String _supabaseUrl =
      'https://ipktwifbornanhrntvlb.supabase.co';
  static const String _table = 'school_progress';

  /// PUBLISHABLE KEY — ISI DARI DASHBOARD SUPABASE proyek school_progress
  /// (bukan service_role!).
  /// Dashboard > pilih project school_progress > Settings (gerigi kiri bawah)
  /// > API > Project API keys > salin key "Publishable".
  /// JANGAN pernah isi service_role key di aplikasi.
  static const String supabaseAnonKey = 'sb_publishable_yQKdmQJ5HRM6o0mcP6ravQ_5ShHBcUm';

  /// Daftar siswa Sekolah Nihongo Santai.
  /// key = student_key di Supabase, name = display_name.
  static const List<(String, String)> students = [
    ('cecilia', 'Cecilia'),
    ('ferdi', 'Ferdi Yanto'),
    ('villia', 'Villia Ivana'),
    ('yusrizal', 'Yusrizal'),
  ];

  static String displayNameFor(String key) {
    for (final s in students) {
      if (s.$1 == key) return s.$2;
    }
    return key;
  }

  /// Buat kunci unik dari nama yang diketik siswa baru.
  /// Mis. 'Budi Santoso' -> 'budi-santoso-k7x2' (4 karakter acak di
  /// belakang supaya dua orang bernama sama tidak bentrok di satu baris).
  static String newStudentKey(String displayName) {
    var slug = displayName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) slug = 'siswa';
    if (slug.length > 20) {
      slug = slug.substring(0, 20).replaceAll(RegExp(r'-+$'), '');
    }
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final rand = math.Random();
    final suffix =
        List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
    return '$slug-$suffix';
  }

  /// Jumlah pelajaran per level — dari lib/data/lessons.dart
  /// (48 pelajaran: N5=19, N4=10, N3=8, N2=6, N1=5).
  ///
  /// Level tampil = level TERTINGGI yang SEMUA pelajarannya selesai;
  /// bila belum ada level yang tuntas, tampil N5 (semua siswa mulai N5).
  /// Level naik BERURUTAN: pelajaran N4 yang selesai lebih dulu tidak
  /// menaikkan gelar sebelum semua pelajaran N5 tuntas.
  ///
  /// Ambang kumulatif (pelajaran selesai): N5 tuntas di 19, N4 di 29,
  /// N3 di 37, N2 di 43, N1 di 48.
  static String computeLevel(AppState s) {
    const order = ['N5', 'N4', 'N3', 'N2', 'N1'];
    var current = 'N5';
    for (final lvl in order) {
      final allDone = lessons
          .where((l) => l.level == lvl)
          .every((l) => s.done.containsKey(l.id));
      if (allDone) {
        current = lvl;
      } else {
        break;
      }
    }
    return current;
  }

  /// Bangun payload dari state lokal. Dipanggil ulang setiap kali kirim,
  /// jadi tidak ada payload basi yang tersimpan.
  /// Hanya dipanggil bila s.studentKey != null (dijaga syncNow/flushPending).
  Map<String, dynamic> buildPayload(AppState s) {
    final key = s.studentKey!;
    return {
      'student_key': key,
      // Nama ketikan sendiri diutamakan; siswa lama pakai daftar di atas.
      'display_name': (s.studentName?.trim().isNotEmpty ?? false)
          ? s.studentName!.trim()
          : displayNameFor(key),
      'level': computeLevel(s),
      'lessons_done': s.lessonsDone,
      'xp': s.xp,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Ambil daftar siswa terbaru dari Supabase (untuk tab Sekolah).
  /// Tidak pernah throw: gagal -> daftar kosong + pesan error.
  Future<({List<SchoolStudent> students, String? error})>
      fetchRoster() async {
    final uri = Uri.parse(
      '$_supabaseUrl/rest/v1/$_table?select=student_key,display_name,level,lessons_done,xp&order=xp.desc',
    );
    try {
      final res = await http.get(
        uri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      ).timeout(const Duration(seconds: 30));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return (
          students: const <SchoolStudent>[],
          error: 'Supabase ${res.statusCode}'
        );
      }
      final raw = jsonDecode(res.body) as List;
      final list = raw.map((r) {
        final m = r as Map<String, dynamic>;
        return SchoolStudent(
          key: (m['student_key'] as String?) ?? '',
          name: (m['display_name'] as String?) ?? '',
          level: (m['level'] as String?) ?? 'N5',
          lessonsDone: (m['lessons_done'] as num?)?.toInt() ?? 0,
          xp: (m['xp'] as num?)?.toInt() ?? 0,
        );
      }).where((s) => s.key.isNotEmpty).toList();
      return (students: list, error: null);
    } on TimeoutException {
      return (
        students: const <SchoolStudent>[],
        error: 'Koneksi ke Sekolah lambat (lebih dari 30 detik). Coba lagi.',
      );
    } catch (e) {
      return (
        students: const <SchoolStudent>[],
        error: 'Tidak terhubung ke Sekolah.\n$e',
      );
    }
  }

  /// Kirim snapshot sekarang (fire-and-forget). Aman dipanggil dari mana
  /// saja: tidak di-await, tidak throw, tidak mengubah UI.
  void syncNow(AppState s) {
    if (s.studentKey == null) return; // identitas belum dipilih
    if (s.forceOffline) return; // pengguna memaksa offline
    _send(s);
  }

  /// Coba kirim antrean tertunda (dipanggil saat aplikasi dibuka).
  void flushPending(AppState s) {
    if (s.studentKey == null || s.forceOffline) return;
    if (!s.schoolPending) return;
    _send(s);
  }

  Future<void> _send(AppState s) async {
    final uri = Uri.parse(
      '$_supabaseUrl/rest/v1/$_table?on_conflict=student_key',
    );
    try {
      final res = await http
          .post(
            uri,
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': 'application/json',
              // Upsert: baris student_key yang sama ditimpa, bukan dobel.
              'Prefer': 'resolution=merge-duplicates',
            },
            body: jsonEncode(buildPayload(s)),
          )
          .timeout(const Duration(seconds: 30));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        s.clearSchoolPending();
      } else {
        s.markSchoolPending();
      }
    } catch (_) {
      // Offline / timeout / Supabase tidak terjangkau: antre saja.
      s.markSchoolPending();
    }
  }
}
