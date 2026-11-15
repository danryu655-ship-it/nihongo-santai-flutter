import 'package:flutter_tts/flutter_tts.dart';

/// Pembungkus flutter_tts untuk pengucapan bahasa Jepang (ja-JP).
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _hasJapanese = false;

  /// Siapkan TTS. Kembalikan true bila ada voice Jepang yang bisa dipakai.
  Future<bool> ensureReady() async {
    if (_ready) return _hasJapanese;
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.7);
      await _tts.setPitch(1.0);
      dynamic avail;
      try {
        avail = await _tts.isLanguageAvailable('ja-JP');
      } catch (_) {
        avail = null;
      }
      if (avail is bool) {
        _hasJapanese = avail;
      } else {
        // Bila API tidak memberi jawaban pasti, coba lihat daftar bahasa.
        try {
          final langs = await _tts.getLanguages;
          if (langs is List) {
            _hasJapanese = langs.any(
              (l) => l.toString().toLowerCase().startsWith('ja'),
            );
          } else {
            _hasJapanese = true; // tidak bisa dipastikan — coba ucapkan saja
          }
        } catch (_) {
          _hasJapanese = true;
        }
      }
    } catch (_) {
      _hasJapanese = false;
    }
    _ready = true;
    return _hasJapanese;
  }

  /// Ucapkan [text]. Kembalikan false bila voice Jepang tidak tersedia.
  /// Kecepatan 0.7 (pelan, untuk pelajar) + bahasa ja-JP diterapkan ulang
  /// sebelum SETIAP ucapan — di Android setting TTS kadang tidak menempel
  /// bila hanya di-set sekali saat init.
  Future<bool> speak(String text) async {
    final ok = await ensureReady();
    if (!ok) return false;
    try {
      await _tts.stop();
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.7);
      await _tts.setPitch(1.0);
      await _tts.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
