import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/dictionary.dart';
import '../services/store.dart';
import '../services/translate_service.dart';
import '../services/tts_service.dart';
import '../widgets.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key, required this.state});

  final AppState state;

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen>
    with WidgetsBindingObserver {
  final _dictCtrl = TextEditingController();
  final _trCtrl = TextEditingController();
  List<DictEntry> _dictResults = [];
  String _trResult = '';
  String _trNote = '';
  bool _translating = false;
  bool? _online; // null = belum dicek
  TtsLang _src = TtsLang.ja;
  TtsLang _dst = TtsLang.id;
  bool _srcAuto = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _probe();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dictCtrl.dispose();
    _trCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Aplikasi kembali ke foreground (mis. setelah pindah aplikasi /
    // hidupkan data): cek ulang koneksi supaya chip tidak merah selamanya.
    if (state == AppLifecycleState.resumed) _probe();
  }

  Future<void> _probe() async {
    if (widget.state.forceOffline) {
      setState(() => _online = false);
      return;
    }
    final ok = await probeOnline();
    if (mounted) setState(() => _online = ok);
  }

  /// Cek ulang manual lewat ketuk chip status.
  Future<void> _recheck() async {
    if (widget.state.forceOffline) return;
    setState(() => _online = null); // tampil "⏳ Mengecek koneksi…"
    await _probe();
  }

  void _onDictChanged(String q) {
    setState(() => _dictResults = searchDictionary(q));
  }

  Future<void> _doTranslate() async {
    final text = _trCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _trResult = '';
        _trNote = 'Tulis dulu teks yang mau diterjemahkan.';
      });
      return;
    }
    setState(() {
      _translating = true;
      _trResult = '';
      _trNote = '';
    });
    String? out;
    String note;
    var onlineOk = false;
    final srcCode = _srcAuto ? 'auto' : _src.code;
    if (!widget.state.forceOffline && _online != false) {
      out = await translateOnline(text, srcCode, _dst);
      if (out != null) {
        // Bukti nyata internet jalan: terjemah online berhasil.
        onlineOk = true;
        note = 'Diterjemahkan online (Google Translate).';
      } else {
        out = offlineTranslate(text, _dst);
        note = out == null
            ? 'Online gagal & tidak ada di kamus offline. Coba kata lain.'
            : 'Online gagal — hasil dari kamus offline.';
      }
    } else {
      out = offlineTranslate(text, _dst);
      note = out == null
          ? 'Mode offline: tidak ditemukan di kamus. Coba kata lain.'
          : 'Hasil dari kamus offline.';
    }
    if (!mounted) return;
    setState(() {
      _translating = false;
      _trResult = out ?? '';
      _trNote = note;
      if (onlineOk) _online = true;
    });
  }

  Future<void> _speak(String text) async {
    final ok = await TtsService.instance.speak(text);
    if (!mounted) return;
    if (!ok) {
      showMsg(
        context,
        'Tidak ada suara Jepang di HP ini. Aktifkan Google Text-to-Speech bahasa Jepang di pengaturan HP.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildNetRow(),
        const SectionTitle('Terjemah online', icon: '🌐'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _trCtrl,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Tulis teks Jepang / Indonesia / Inggris…',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _srcAuto ? 'auto' : _src.code,
                      decoration: const InputDecoration(
                        labelText: 'Dari',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'auto', child: Text('Otomatis')),
                        DropdownMenuItem(
                            value: 'ja', child: Text('Jepang')),
                        DropdownMenuItem(
                            value: 'id', child: Text('Indonesia')),
                        DropdownMenuItem(
                            value: 'en', child: Text('Inggris')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          if (v == 'auto') {
                            _srcAuto = true;
                          } else {
                            _srcAuto = false;
                            _src = TtsLang.values
                                .firstWhere((e) => e.code == v);
                          }
                        });
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tukar bahasa',
                    onPressed: () {
                      setState(() {
                        final tmp = _dst;
                        _dst = _srcAuto ? TtsLang.ja : _src;
                        _src = tmp;
                        _srcAuto = false;
                      });
                    },
                    icon: const Icon(Icons.swap_horiz, color: brand),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<TtsLang>(
                      value: _dst,
                      decoration: const InputDecoration(
                        labelText: 'Ke',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: TtsLang.values
                          .map(
                            (l) => DropdownMenuItem(
                              value: l,
                              child: Text(l.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _dst = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: _translating ? 'Menerjemahkan…' : 'Terjemahkan',
                icon: Icons.translate,
                onPressed: _translating ? null : _doTranslate,
              ),
              if (_trResult.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: brandLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    _trResult,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _trResult));
                        showMsg(context, 'Disalin.');
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Salin'),
                    ),
                    TextButton.icon(
                      onPressed: () => _speak(_trResult),
                      icon: const Icon(Icons.volume_up, size: 18),
                      label: const Text('Dengarkan'),
                    ),
                  ],
                ),
              ],
              if (_trNote.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _trNote,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SectionTitle('Cari di kamus (489 kata)', icon: '📖'),
        TextField(
          controller: _dictCtrl,
          onChanged: _onDictChanged,
          decoration: InputDecoration(
            hintText: 'Cari Jepang / kana / romaji / Indonesia / Inggris…',
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
        if (_dictCtrl.text.isEmpty)
          const Text(
            'Ketik untuk mencari di kamus. Contoh: こんにちは, konnichiwa, halo, hello.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          )
        else if (_dictResults.isEmpty)
          const Text(
            'Tidak ditemukan di kamus. Coba kata lain, atau lihat tab Frasa.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          )
        else
          ..._dictResults.map(_wordCard),
        const SectionTitle('Terakhir dilihat', icon: '🕘'),
        _chips(
          widget.state.recents,
          emptyText: 'Belum ada.',
          star: false,
        ),
        const SectionTitle('Favorit', icon: '⭐'),
        _chips(
          widget.state.favs,
          emptyText: 'Ketuk ⭐ pada sebuah kata untuk menyimpan.',
          star: true,
        ),
      ],
    );
  }

  Widget _buildNetRow() {
    final forced = widget.state.forceOffline;
    final online = _online;
    final label = forced
        ? '🔴 Offline (dipaksa)'
        : online == null
            ? '⏳ Mengecek koneksi…'
            : online
                ? '🟢 Online'
                : '🔴 Offline';
    return Row(
      children: [
        InkWell(
          onTap: forced ? null : _recheck,
          borderRadius: BorderRadius.circular(16),
          child: Chip(
            label: Text(label, style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              final next = !forced;
              widget.state.setForceOffline(next);
              if (next) {
                setState(() => _online = false);
              } else {
                _probe();
              }
            },
            child: Text(
              forced ? 'Matikan "Paksa offline"' : 'Paksa offline',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chips(List<String> keys, {required String emptyText, required bool star}) {
    if (keys.isEmpty) {
      return Text(emptyText,
          style: const TextStyle(color: Colors.grey, fontSize: 13));
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: keys.map((j) {
        final e = dictionary.firstWhere(
          (x) => x.japanese == j,
          orElse: () => dictionary.first,
        );
        return ActionChip(
          label: Text(
            '${star ? '⭐ ' : ''}${e.japanese} — ${e.indonesian}',
            style: const TextStyle(fontSize: 12),
          ),
          onPressed: () {
            _dictCtrl.text = e.japanese;
            _onDictChanged(e.japanese);
          },
        );
      }).toList(),
    );
  }

  Widget _wordCard(DictEntry e) {
    final fav = widget.state.isFav(e.japanese);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  e.japanese,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: fav ? 'Hapus favorit' : 'Simpan favorit',
                onPressed: () {
                  widget.state.toggleFav(e.japanese);
                  setState(() {});
                },
                icon: Icon(
                  fav ? Icons.star : Icons.star_border,
                  color: fav ? Colors.amber : Colors.grey,
                ),
              ),
              IconButton(
                tooltip: 'Salin',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: e.japanese));
                  showMsg(context, 'Disalin: ${e.japanese}');
                },
                icon: const Icon(Icons.copy, size: 20),
              ),
            ],
          ),
          Text(
            '${e.kana} • ${e.romaji}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text('🇮🇩 ${e.indonesian}', style: const TextStyle(fontSize: 15)),
          Text('🇬🇧 ${e.english}', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Chip(
            label: Text(
              dictionaryCategories[e.category] ?? e.category,
              style: const TextStyle(fontSize: 11),
            ),
            backgroundColor: brandLight,
            visualDensity: VisualDensity.compact,
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  widget.state.addRecent(e.japanese);
                  _speak(e.japanese);
                },
                icon: const Icon(Icons.volume_up, size: 18),
                label: const Text('Dengarkan'),
              ),
              TextButton(
                onPressed: () {
                  widget.state.addRecent(e.japanese);
                  setState(() {});
                  showMsg(context, 'Ditandai sebagai terakhir dilihat.');
                },
                child: const Text('Tandai dilihat'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
