import 'package:flutter/material.dart';

import '../services/school_sync.dart';
import '../services/store.dart';
import '../widgets.dart';

/// Pemilih identitas siswa — tampil sekali saat pertama pakai aplikasi,
/// sebelum masuk tab. Siswa menulis namanya sendiri supaya progres
/// terkirim atas nama yang benar ke Sekolah Nihongo Santai.
///
/// Dipanggil dari lib/main.dart (_HomePageState.build) bila
/// state.studentKey == null. Setelah disimpan, kirim snapshot awal
/// (0 pelajaran, N5) supaya baris siswa langsung muncul di Supabase.
class StudentPickerScreen extends StatefulWidget {
  const StudentPickerScreen({
    super.key,
    required this.state,
    required this.onSaved,
  });

  final AppState state;
  final VoidCallback onSaved;

  @override
  State<StudentPickerScreen> createState() => _StudentPickerScreenState();
}

class _StudentPickerScreenState extends State<StudentPickerScreen> {
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            const Text(
              '🎌',
              style: TextStyle(fontSize: 48),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Siapa yang belajar?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tulis namamu supaya progres belajarmu tercatat di '
              'Sekolah Nihongo Santai dan gelarmu (N5–N1) tampil di sana.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppCard(
              child: TextField(
                controller: _nameCtrl,
                maxLength: 30,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Tulis namamu',
                  hintText: 'cth: Budi Santoso',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Namamu langsung muncul di Sekolah Nihongo Santai, '
              'gelarmu (N5–N1) mengikuti pelajaran yang sudah kamu selesaikan.',
              style: TextStyle(fontSize: 12, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Simpan & mulai belajar',
              onPressed: _nameCtrl.text.trim().isEmpty
                  ? null
                  : () {
                      final typed = _nameCtrl.text.trim();
                      // Buat kunci unik dari nama ketikan.
                      final key = SchoolSyncService.newStudentKey(typed);
                      widget.state.setStudentKey(key);
                      widget.state.setStudentName(typed);
                      // Kirim baris awal (0 pelajaran, N5) ke Supabase.
                      SchoolSyncService.instance.syncNow(widget.state);
                      widget.onSaved();
                    },
            ),
            const SizedBox(height: 12),
            const Text(
              'Satu HP = satu siswa. Kalau HP dipakai bergantian, '
              'hapus data aplikasi untuk memilih ulang (progres lokal ikut terhapus).',
              style: TextStyle(fontSize: 12, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
