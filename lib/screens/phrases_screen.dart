import 'package:flutter/material.dart';

import '../data/menu.dart';
import '../data/phrases.dart';
import '../services/tts_service.dart';
import '../widgets.dart';

class PhrasesScreen extends StatefulWidget {
  const PhrasesScreen({super.key, required this.state});

  final dynamic state; // AppState tidak dipakai di sini, dipertahankan untuk konsistensi

  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen> {
  String _view = 'hub'; // hub | frasa | menu

  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case 'frasa':
        return _PhraseListView(onBack: () => setState(() => _view = 'hub'));
      case 'menu':
        return _MenuView(onBack: () => setState(() => _view = 'hub'));
      default:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AppCard(
              onTap: () => setState(() => _view = 'frasa'),
              child: Row(
                children: [
                  const Text('💬', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kartu Frasa',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('67 frasa perjalanan • ketuk untuk mendengarkan',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              onTap: () => setState(() => _view = 'menu'),
              child: Row(
                children: [
                  const Text('🍜', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Menu & Alergi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('41 kata menu + kartu alergi & diet',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        );
    }
  }
}

Future<void> _speak(BuildContext context, String text) async {
  final ok = await TtsService.instance.speak(text);
  if (!context.mounted) return;
  if (!ok) {
    showMsg(
      context,
      'Tidak ada suara Jepang di HP ini. Aktifkan Google Text-to-Speech bahasa Jepang di pengaturan HP.',
    );
  }
}

/// Dialog kartu besar dengan tombol dengarkan.
void _showBigCard(
  BuildContext context, {
  required String japanese,
  required String romaji,
  required String indonesian,
  String? extra,
  String? hint,
}) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                japanese,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(romaji,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(indonesian,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
              if (extra != null) ...[
                const SizedBox(height: 8),
                Text(extra,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center),
              ],
              if (hint != null) ...[
                const SizedBox(height: 8),
                Text(hint,
                    style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: brand),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: '🔊 Dengarkan',
                onPressed: () => _speak(ctx, japanese),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------- Daftar frasa ----------------

class _PhraseListView extends StatefulWidget {
  const _PhraseListView({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_PhraseListView> createState() => _PhraseListViewState();
}

class _PhraseListViewState extends State<_PhraseListView> {
  String _query = '';
  String _cat = 'Semua';

  @override
  Widget build(BuildContext context) {
    final cats = <String>['Semua'];
    for (final p in phrases) {
      if (!cats.contains(p.category)) cats.add(p.category);
    }
    final filtered = phrases.where((p) {
      if (_cat != 'Semua' && p.category != _cat) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return p.japanese.contains(_query) ||
          p.romaji.toLowerCase().contains(q) ||
          p.indonesian.toLowerCase().contains(q) ||
          (p.english ?? '').toLowerCase().contains(q);
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const Text('Kartu Frasa (67)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Cari frasa…',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: cats
              .map(
                (c) => ChoiceChip(
                  label: Text(c, style: const TextStyle(fontSize: 12)),
                  selected: _cat == c,
                  selectedColor: brandLight,
                  onSelected: (_) => setState(() => _cat = c),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          const Text('Tidak ada frasa yang cocok.',
              style: TextStyle(color: Colors.grey))
        else
          for (final p in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => _showBigCard(
                  context,
                  japanese: p.japanese,
                  romaji: p.romaji,
                  indonesian: p.indonesian,
                  extra: p.english,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.japanese,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Text('${p.romaji} • ${p.indonesian}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                          Text(p.category,
                              style: const TextStyle(
                                  fontSize: 11, color: brand)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dengarkan',
                      onPressed: () => _speak(context, p.japanese),
                      icon: const Icon(Icons.volume_up, color: brand),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

// ---------------- Menu + kartu alergi/diet ----------------

class _MenuView extends StatefulWidget {
  const _MenuView({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<_MenuView> {
  String _query = '';
  final Set<int> _pickedAllergy = {};
  String? _diet; // id dietOptions, null = tidak ada

  void _showAllergyCard() {
    if (_pickedAllergy.isEmpty && _diet == null) {
      showMsg(context, 'Pilih dulu alergi atau dietmu.');
      return;
    }
    final ja = <String>[];
    final tr = <String>[];
    if (_pickedAllergy.isNotEmpty) {
      ja.add('アレルギーがあります。');
      tr.add('Saya punya alergi.');
      final names = _pickedAllergy
          .map((i) => allergyItems[i].japanese)
          .join('、');
      ja.add('$namesは食べられません。');
      tr.add(
        'Saya tidak bisa makan: ${_pickedAllergy.map((i) => allergyItems[i].indonesian.toLowerCase()).join(', ')}.',
      );
    }
    if (_diet != null) {
      final d = dietOptions.firstWhere((x) => x.id == _diet);
      ja.add(d.japanese);
      tr.add(d.indonesian);
    }
    _showBigCard(
      context,
      japanese: ja.join('\n'),
      romaji: 'arerugī kādo',
      indonesian: tr.join(' '),
      hint: 'Tunjukkan kartu ini ke staf restoran',
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = menuItems.where((m) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return m.japanese.contains(_query) ||
          m.romaji.toLowerCase().contains(q) ||
          m.indonesian.toLowerCase().contains(q);
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const Text('Menu & Alergi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SectionTitle('Kartu alergi & diet', icon: '⚠️'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alergiku:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: allergyItems.asMap().entries.map((e) {
                  final sel = _pickedAllergy.contains(e.key);
                  return FilterChip(
                    label: Text(
                      '${e.value.japanese} (${e.value.indonesian})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: sel,
                    selectedColor: const Color(0xFFFEE2E2),
                    onSelected: (_) {
                      setState(() {
                        if (sel) {
                          _pickedAllergy.remove(e.key);
                        } else {
                          _pickedAllergy.add(e.key);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Text('Diet:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String?>(
                value: _diet,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tidak ada'),
                  ),
                  ...dietOptions.map(
                    (d) => DropdownMenuItem<String?>(
                      value: d.id,
                      child: Text(d.indonesian),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _diet = v),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Tampilkan Kartu Alergi',
                icon: Icons.credit_card,
                onPressed: _showAllergyCard,
              ),
            ],
          ),
        ),
        const SectionTitle('Decoder menu (41 kata)', icon: '🍜'),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Cari kata menu…',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          const Text('Tidak ada kata yang cocok.',
              style: TextStyle(color: Colors.grey))
        else
          for (final m in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => _showBigCard(
                  context,
                  japanese: m.japanese,
                  romaji: m.romaji,
                  indonesian: m.indonesian,
                  extra: m.category,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.japanese,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Text('${m.romaji} • ${m.indonesian}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dengarkan',
                      onPressed: () => _speak(context, m.japanese),
                      icon: const Icon(Icons.volume_up, color: brand),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
