import 'package:flutter/material.dart';

import '../services/school_sync.dart';
import '../services/store.dart';
import '../widgets.dart';

/// Pemilih identitas siswa — tampil sekali saat pertama pakai aplikasi,
/// sebelum masuk tab. Wajib pilih supaya progres terkirim atas nama yang
/// benar ke Sekolah Nihongo Santai.
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
  String? _picked;
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
              'Pilih namamu, atau tulis nama baru kalau namamu belum ada — '
              'progres belajarmu tercatat di Sekolah Nihongo Santai dan '
              'gelarmu (N5–N1) tampil di sana.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...SchoolSyncService.students.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: RadioListTile<String>(
                    value: s.$1,
                    groupValue: _picked,
                    onChanged: (v) => setState(() => _picked = v),
                    title: Text(
                      s.$2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Kelas Sakura • mulai dari N5'),
                    activeColor: brand,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child:
                      Text('atau', style: TextStyle(color: Colors.black54)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: TextField(
                controller: _nameCtrl,
                maxLength: 30,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Tulis namamu (siswa baru)',
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
              onPressed: (_picked == null && _nameCtrl.text.trim().isEmpty)
                  ? null
                  : () {
                      final typed = _nameCtrl.text.trim();
                      if (typed.isNotEmpty) {
                        // Siswa baru: buat kunci unik dari nama ketikan.
                        final key =
                            SchoolSyncService.newStudentKey(typed);
                        widget.state.setStudentKey(key);
                        widget.state.setStudentName(typed);
                      } else {
                        widget.state.setStudentKey(_picked!);
                      }
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
