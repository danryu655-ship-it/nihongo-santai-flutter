import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/trip.dart';
import '../services/store.dart';
import '../widgets.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key, required this.state});

  final AppState state;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  // Perencana
  late String _city;
  final _daysCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // Itinerary
  final _itinDayCtrl = TextEditingController(text: '1');
  final _itinTimeCtrl = TextEditingController(text: '09:00');
  final _itinActCtrl = TextEditingController();

  // Penerbangan
  final _airlineCtrl = TextEditingController();
  final _flightNoCtrl = TextEditingController();
  final _flightDateCtrl = TextEditingController();
  final _depTimeCtrl = TextEditingController();
  final _arrTimeCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  // Dokumen
  final _docTypeCtrl = TextEditingController();
  final _docCodeCtrl = TextEditingController();
  final _docNoteCtrl = TextEditingController();

  // Wishlist & pengeluaran
  final _wishCtrl = TextEditingController();
  final _expNameCtrl = TextEditingController();
  final _expAmtCtrl = TextEditingController();

  bool _exportingPdf = false;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _city = s.tripCity;
    _daysCtrl.text = s.tripDays.toString();
    _budgetCtrl.text = s.tripBudget.toString();
    _noteCtrl.text = s.tripNote;
    _fillFlight();
  }

  void _fillFlight() {
    final f = widget.state.flight;
    _airlineCtrl.text = f['airline'] ?? '';
    _flightNoCtrl.text = f['number'] ?? '';
    _flightDateCtrl.text = f['date'] ?? '';
    _depTimeCtrl.text = f['depTime'] ?? '';
    _arrTimeCtrl.text = f['arrTime'] ?? '';
    _fromCtrl.text = f['from'] ?? '';
    _toCtrl.text = f['to'] ?? '';
  }

  @override
  void dispose() {
    _daysCtrl.dispose();
    _budgetCtrl.dispose();
    _noteCtrl.dispose();
    _itinDayCtrl.dispose();
    _itinTimeCtrl.dispose();
    _itinActCtrl.dispose();
    _airlineCtrl.dispose();
    _flightNoCtrl.dispose();
    _flightDateCtrl.dispose();
    _depTimeCtrl.dispose();
    _arrTimeCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _docTypeCtrl.dispose();
    _docCodeCtrl.dispose();
    _docNoteCtrl.dispose();
    _wishCtrl.dispose();
    _expNameCtrl.dispose();
    _expAmtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text(
          'Rencana Trip ke Jepang',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Semua data tersimpan di HP ini (mulai dari nol).',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        _plannerCard(),
        _itinCard(),
        _flightCard(),
        _docsCard(),
        _packCard(),
        _wishCard(),
        _expenseCard(),
        _splitCard(),
        _pdfCard(),
      ],
    );
  }

  // ---------- 1. Perencana Trip ----------
  Widget _plannerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Perencana Trip', icon: '🗺️'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kota tujuan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _city,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                items: tripCities
                    .map(
                      (c) => DropdownMenuItem(
                        value: '${c.name}|${c.japanese}',
                        child: Text('${c.name} ${c.japanese}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _city = v);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _daysCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Jumlah hari',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _budgetCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Budget (JPY)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Simpan Rencana',
                icon: Icons.save,
                onPressed: () {
                  final days = int.tryParse(_daysCtrl.text) ?? 3;
                  final budget = int.tryParse(_budgetCtrl.text) ?? 0;
                  widget.state.saveTrip(
                    city: _city,
                    days: days.clamp(1, 60),
                    budget: budget,
                    note: _noteCtrl.text.trim(),
                  );
                  showMsg(context, 'Rencana trip disimpan.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 2. Itinerary Harian ----------
  Widget _itinCard() {
    final s = widget.state;
    final days = <int>{};
    for (final it in s.itin) {
      days.add((it['day'] as num).toInt());
    }
    final sortedDays = days.toList()..sort();
    final tpl = tripTemplates.firstWhere(
      (t) => t.cityName == s.tripCityName,
      orElse: () => tripTemplates.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Itinerary Harian', icon: '📅'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.itin.isEmpty)
                const Text('Belum ada jadwal. Tambah manual atau pakai template.',
                    style: TextStyle(color: Colors.grey, fontSize: 13))
              else
                for (final d in sortedDays) ...[
                  Text('Hari $d',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  for (var i = 0; i < s.itin.length; i++)
                    if ((s.itin[i]['day'] as num).toInt() == d)
                      _itinRow(s, i),
                  const SizedBox(height: 8),
                ],
              const Divider(),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _itinDayCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Hari',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _itinTimeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Jam (09:00)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: TextField(
                      controller: _itinActCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kegiatan',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final day =
                            int.tryParse(_itinDayCtrl.text.trim()) ?? 1;
                        final act = _itinActCtrl.text.trim();
                        if (act.isEmpty) {
                          showMsg(context, 'Tulis dulu kegiatannya.');
                          return;
                        }
                        widget.state.addItin(
                          day.clamp(1, 60),
                          _itinTimeCtrl.text.trim().isEmpty
                              ? '09:00'
                              : _itinTimeCtrl.text.trim(),
                          act,
                        );
                        _itinActCtrl.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('+ Tambah'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _applyTemplate(tpl),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: Text('Pakai Template ${tpl.cityName}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itinRow(AppState s, int i) {
    final it = s.itin[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              (it['time'] ?? '').toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text((it['activity'] ?? '').toString())),
          IconButton(
            tooltip: 'Hapus',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              widget.state.delItin(i);
              setState(() {});
            },
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTemplate(TripTemplate tpl) async {
    final s = widget.state;
    final existingDays = <int>{
      for (final it in s.itin) (it['day'] as num).toInt(),
    };
    final clashDays = <int>{
      for (final it in tpl.items)
        if (existingDays.contains(it.day)) it.day,
    };
    if (clashDays.isNotEmpty) {
      final sorted = clashDays.toList()..sort();
      final ok = await confirmDialog(
        context,
        'Hari sudah terisi',
        'Hari ${sorted.join(', ')} sudah ada isinya. Template hanya mengisi hari yang masih kosong. Lanjutkan?',
      );
      if (!ok) return;
    }
    if (!mounted) return;
    final toAdd = tpl.items
        .where((it) => !existingDays.contains(it.day))
        .map((it) => {
              'day': it.day,
              'time': it.time,
              'activity': it.activity,
            })
        .toList();
    if (toAdd.isEmpty) {
      showMsg(context, 'Semua hari template sudah terisi — tidak ada yang ditambahkan.');
      return;
    }
    widget.state.applyTemplate(toAdd);
    setState(() {});
    showMsg(context, '${toAdd.length} kegiatan dari template ${tpl.cityName} ditambahkan.');
  }

  // ---------- 3. Info Penerbangan ----------
  Widget _flightCard() {
    final hasFlight = widget.state.flight.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Info Penerbangan', icon: '✈️'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasFlight) ...[
                _flightLine('Maskapai', widget.state.flight['airline']),
                _flightLine('Nomor', widget.state.flight['number']),
                _flightLine('Tanggal', widget.state.flight['date']),
                _flightLine('Berangkat',
                    '${widget.state.flight['depTime'] ?? ''} dari ${widget.state.flight['from'] ?? ''}'),
                _flightLine('Tiba',
                    '${widget.state.flight['arrTime'] ?? ''} di ${widget.state.flight['to'] ?? ''}'),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _airlineCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Maskapai',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _flightNoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nomor penerbangan',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _flightDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  hintText: 'Ketuk untuk memilih tanggal',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2026),
                    lastDate: DateTime(2028),
                  );
                  if (picked != null) {
                    _flightDateCtrl.text =
                        '${picked.day}/${picked.month}/${picked.year}';
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _depTimeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Jam berangkat',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _arrTimeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Jam tiba',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fromCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bandara berangkat',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _toCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bandara tiba',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Simpan Penerbangan',
                      onPressed: () {
                        widget.state.saveFlight({
                          'airline': _airlineCtrl.text.trim(),
                          'number': _flightNoCtrl.text.trim(),
                          'date': _flightDateCtrl.text.trim(),
                          'depTime': _depTimeCtrl.text.trim(),
                          'arrTime': _arrTimeCtrl.text.trim(),
                          'from': _fromCtrl.text.trim(),
                          'to': _toCtrl.text.trim(),
                        });
                        setState(() {});
                        showMsg(context, 'Info penerbangan disimpan.');
                      },
                    ),
                  ),
                  if (hasFlight) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await confirmDialog(context,
                            'Hapus penerbangan', 'Hapus info penerbangan?');
                        if (!ok) return;
                        if (!context.mounted) return;
                        widget.state.clearFlight();
                        _fillFlight();
                        setState(() {});
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _flightLine(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ---------- 4. Dokumen & Tiket ----------
  Widget _docsCard() {
    final s = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Dokumen & Tiket', icon: '🎫'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.docs.isEmpty)
                const Text('Belum ada dokumen.',
                    style: TextStyle(color: Colors.grey, fontSize: 13))
              else
                for (var i = 0; i < s.docs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (s.docs[i]['type'] ?? '').toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Kode: ${(s.docs[i]['code'] ?? '').toString()}${(s.docs[i]['note'] ?? '').toString().isEmpty ? '' : ' • ${(s.docs[i]['note'] ?? '').toString()}'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            widget.state.delDoc(i);
                            setState(() {});
                          },
                          icon: const Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              const Divider(),
              TextField(
                controller: _docTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jenis (mis. Paspor / Tiket pesawat)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _docCodeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kode konfirmasi',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _docNoteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_docTypeCtrl.text.trim().isEmpty) {
                      showMsg(context, 'Isi dulu jenis dokumennya.');
                      return;
                    }
                    widget.state.addDoc(
                      _docTypeCtrl.text.trim(),
                      _docCodeCtrl.text.trim(),
                      _docNoteCtrl.text.trim(),
                    );
                    _docTypeCtrl.clear();
                    _docCodeCtrl.clear();
                    _docNoteCtrl.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('+ Tambah Dokumen'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 5. Packing ----------
  Widget _packCard() {
    final s = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Packing Checklist', icon: '🎒'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${s.packDone.length} / ${packingList.length} barang siap',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: s.packDone.length / packingList.length,
                backgroundColor: Colors.grey.shade200,
                color: brand,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              for (var i = 0; i < packingList.length; i++)
                CheckboxListTile(
                  value: s.packDone.contains(i),
                  onChanged: (_) {
                    widget.state.togglePack(i);
                    setState(() {});
                  },
                  title: Text(packingList[i].japanese,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${packingList[i].romaji} • ${packingList[i].indonesian}'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 6. Wishlist ----------
  Widget _wishCard() {
    final s = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Wishlist', icon: '💝'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.wishes.isEmpty)
                const Text('Belum ada wishlist.',
                    style: TextStyle(color: Colors.grey, fontSize: 13))
              else
                for (var i = 0; i < s.wishes.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text('• ${s.wishes[i]}')),
                        IconButton(
                          tooltip: 'Hapus',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            widget.state.delWish(i);
                            setState(() {});
                          },
                          icon: const Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wishCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Oleh-oleh KitKat matcha',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final w = _wishCtrl.text.trim();
                      if (w.isEmpty) return;
                      widget.state.addWish(w);
                      _wishCtrl.clear();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('+ Tambah'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 7. Pengeluaran ----------
  Widget _expenseCard() {
    final s = widget.state;
    final total = s.totalExpense;
    final sisa = s.tripBudget - total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Pengeluaran', icon: '💴'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.expenses.isEmpty)
                const Text('Belum ada pengeluaran.',
                    style: TextStyle(color: Colors.grey, fontSize: 13))
              else
                for (var i = 0; i < s.expenses.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                              (s.expenses[i]['name'] ?? '').toString()),
                        ),
                        Text(
                          fmtJPY((s.expenses[i]['amt'] as num?) ?? 0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            widget.state.delExpense(i);
                            setState(() {});
                          },
                          icon: const Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _expNameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Tiket kereta',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _expAmtCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'JPY',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final name = _expNameCtrl.text.trim();
                      final amt = int.tryParse(_expAmtCtrl.text) ?? 0;
                      if (name.isEmpty || amt <= 0) {
                        showMsg(context, 'Isi nama dan jumlah (JPY) dulu.');
                        return;
                      }
                      widget.state.addExpense(name, amt);
                      _expNameCtrl.clear();
                      _expAmtCtrl.clear();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('+ Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Total keluar: ${fmtJPY(total)} • Budget: ${fmtJPY(s.tripBudget)} • Sisa: ${fmtJPY(sisa)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: sisa < 0 ? badRed : okGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 8. Bagi Biaya ----------
  Widget _splitCard() {
    final s = widget.state;
    final total = s.totalExpense;
    final per = s.splitPeople > 0 ? total ~/ s.splitPeople : total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Bagi Biaya', icon: '🧾'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Jumlah orang: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () {
                      widget.state.setSplitPeople(s.splitPeople - 1);
                      setState(() {});
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: brand,
                  ),
                  Text('${s.splitPeople}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () {
                      widget.state.setSplitPeople(s.splitPeople + 1);
                      setState(() {});
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: brand,
                  ),
                ],
              ),
              Text(
                'Per orang: ${fmtJPY(per)}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: brand),
              ),
              const Text(
                'Dihitung dari total pengeluaran dibagi jumlah orang.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 9. Ekspor PDF ----------
  Widget _pdfCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Ekspor PDF', icon: '🖨️'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Buat ringkasan trip (rencana, itinerary, penerbangan, dokumen, packing, wishlist, pengeluaran) sebagai PDF untuk dibagikan atau dicetak.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: _exportingPdf ? 'Membuat PDF…' : '🖨️ Ekspor / Cetak PDF',
                icon: Icons.picture_as_pdf,
                onPressed: _exportingPdf ? null : _exportPdf,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _exportingPdf = true);
    try {
      final s = widget.state;
      final doc = pw.Document();
      final days = <int>{};
      for (final it in s.itin) {
        days.add((it['day'] as num).toInt());
      }
      final sortedDays = days.toList()..sort();
      final sortedItin = [...s.itin]
        ..sort((a, b) {
          final da = (a['day'] as num).toInt();
          final db = (b['day'] as num).toInt();
          if (da != db) return da.compareTo(db);
          return (a['time'] ?? '').toString().compareTo(
                (b['time'] ?? '').toString(),
              );
        });

      pw.Widget h(String t) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
            child: pw.Text(
              t,
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('4338CA'),
              ),
            ),
          );
      pw.Widget p(String t) => pw.Text(t, style: const pw.TextStyle(fontSize: 11));
      pw.Widget bullet(String t) => pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
            child: pw.Text('• $t', style: const pw.TextStyle(fontSize: 11)),
          );

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (ctx) => [
            pw.Text(
              'Ringkasan Trip — Nihongo Santai',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            h('Rencana Trip'),
            p('Kota: ${s.tripCityName} ${s.tripCityJapanese}'),
            p('Jumlah hari: ${s.tripDays}'),
            p('Budget: ${fmtJPY(s.tripBudget)}'),
            if (s.tripNote.isNotEmpty) p('Catatan: ${s.tripNote}'),
            h('Itinerary Harian'),
            if (s.itin.isEmpty)
              p('Belum ada jadwal.')
            else
              ...sortedDays.map(
                (d) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Hari $d',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    ...sortedItin
                        .where((it) => (it['day'] as num).toInt() == d)
                        .map(
                          (it) => bullet(
                            '${it['time']} — ${it['activity']}',
                          ),
                        ),
                  ],
                ),
              ),
            h('Info Penerbangan'),
            if (s.flight.isEmpty)
              p('Belum diisi.')
            else ...[
              p('Maskapai: ${s.flight['airline'] ?? '-'} (${s.flight['number'] ?? '-'})'),
              p('Tanggal: ${s.flight['date'] ?? '-'}'),
              p('Berangkat: ${s.flight['depTime'] ?? '-'} dari ${s.flight['from'] ?? '-'}'),
              p('Tiba: ${s.flight['arrTime'] ?? '-'} di ${s.flight['to'] ?? '-'}'),
            ],
            h('Dokumen & Tiket'),
            if (s.docs.isEmpty)
              p('Belum ada.')
            else
              ...s.docs.map(
                (d) => bullet(
                  '${d['type']} — kode: ${d['code']}${(d['note'] ?? '').toString().isEmpty ? '' : ' (${d['note']})'}',
                ),
              ),
            h('Packing Checklist'),
            p('${s.packDone.length} / ${packingList.length} barang siap'),
            ...packingList.asMap().entries.map(
                  (e) => bullet(
                    '${s.packDone.contains(e.key) ? '[x]' : '[ ]'} ${e.value.japanese} — ${e.value.indonesian}',
                  ),
                ),
            h('Wishlist'),
            if (s.wishes.isEmpty)
              p('Belum ada.')
            else
              ...s.wishes.map(bullet),
            h('Pengeluaran'),
            if (s.expenses.isEmpty)
              p('Belum ada.')
            else
              ...s.expenses.map(
                (e) => bullet('${e['name']}: ${fmtJPY((e['amt'] as num?) ?? 0)}'),
              ),
            p('Total keluar: ${fmtJPY(s.totalExpense)} • Budget: ${fmtJPY(s.tripBudget)} • Sisa: ${fmtJPY(s.tripBudget - s.totalExpense)}'),
            p('Bagi biaya (${s.splitPeople} orang): per orang ${fmtJPY(s.splitPeople > 0 ? s.totalExpense ~/ s.splitPeople : s.totalExpense)}'),
          ],
        ),
      );
      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'ringkasan-trip-nihongo-santai.pdf',
      );
    } catch (e) {
      if (mounted) {
        showMsg(context, 'Gagal membuat PDF: $e');
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }
}
