import 'package:flutter/material.dart';

import '../services/school_sync.dart';
import '../services/store.dart';
import '../widgets.dart';

/// Tab Sekolah: daftar siswa Sekolah Nihongo Santai LIVE dari Supabase.
/// Tiap kartu = avatar (huruf awal nama) + gelar (N5–N1) + progres.
/// Siswa baru yang daftar lewat aplikasi langsung muncul di sini setelah
/// tersimpan di Supabase (tarik ke bawah untuk refresh).
class SchoolScreen extends StatefulWidget {
  const SchoolScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  List<SchoolStudent> _students = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await SchoolSyncService.instance.fetchRoster();
    if (!mounted) return;
    setState(() {
      _students = res.students;
      _error = res.error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.black38),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Coba lagi', onPressed: _load),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Sekolah Nihongo Santai',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${_students.length} siswa • tarik ke bawah untuk refresh',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ..._students.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: brand,
                    foregroundColor: Colors.white,
                    child: Text(
                      s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Kelas Sakura • ${s.level}'),
                  trailing: Text(
                    '${s.lessonsDone} pelajaran\n${s.xp} XP',
                    textAlign: TextAlign.right,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
          if (_students.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'Belum ada siswa. Jadilah yang pertama!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
