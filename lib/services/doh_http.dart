import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// HTTP dengan fallback DNS-over-HTTPS (DoH).
///
/// Latar: DNS sebagian provider seluler tidak bisa me-resolve subdomain
/// Supabase ("Failed host lookup", errno 7) — DNS Pribadi pun tidak
/// berpengaruh bila port DoT ikut diblokir. Fallback ini menyelesaikan
/// alamat lewat DNS-over-HTTPS (dns.google, lalu cloudflare-dns.com),
/// lalu tersambung ke IP hasil resolve dengan SNI + verifikasi sertifikat
/// memakai nama host aslinya (SecureSocket.secure), jadi keamanan TLS
/// tidak diturunkan.
///
/// Dipakai hanya bila panggilan langsung gagal cepat (SocketException /
/// ClientException). Timeout dibiarkan apa adanya — itu jalur lambat,
/// bukan DNS yang gagal.
/// [client] hanya untuk pengujian (tool/test_doh.dart): klien HTTP
/// khusus, mis. yang memakai proxy VM. Aplikasi tidak pernah mengisinya.
Future<({int statusCode, String body})> requestWithDohFallback({
  required String method,
  required Uri uri,
  Map<String, String>? headers,
  String? body,
  Duration timeout = const Duration(seconds: 30),
  http.Client? client,
}) async {
  try {
    final http.Response res;
    if (method == 'POST') {
      res = await (client == null
              ? http.post(uri, headers: headers, body: body)
              : client.post(uri, headers: headers, body: body))
          .timeout(timeout);
    } else {
      res = await (client == null
              ? http.get(uri, headers: headers)
              : client.get(uri, headers: headers))
          .timeout(timeout);
    }
    return (statusCode: res.statusCode, body: res.body);
  } on SocketException catch (e) {
    return await _tryDohOrRethrow(
      e,
      method: method,
      uri: uri,
      headers: headers,
      body: body,
      client: client,
    );
  } on http.ClientException catch (e) {
    return await _tryDohOrRethrow(
      e,
      method: method,
      uri: uri,
      headers: headers,
      body: body,
      client: client,
    );
  }
}

Future<({int statusCode, String body})> _tryDohOrRethrow(
  Object original, {
  required String method,
  required Uri uri,
  Map<String, String>? headers,
  String? body,
  http.Client? client,
}) async {
  try {
    return await requestViaDoh(
      method: method,
      uri: uri,
      headers: headers,
      body: body,
      client: client,
    );
  } catch (_) {
    // Fallback ikut gagal: laporkan error aslinya (untuk diagnostik).
    throw original;
  }
}

/// Jalur fallback saja (tanpa panggilan langsung). Dipakai oleh
/// requestWithDohFallback, dan langsung oleh tool/test_doh.dart untuk
/// membuktikan mekanismenya ke Supabase asli.
Future<({int statusCode, String body})> requestViaDoh({
  required String method,
  required Uri uri,
  Map<String, String>? headers,
  String? body,
  http.Client? client,
}) async {
  final host = uri.host;
  final ips = await resolveIpViaDoh(host, client: client);
  Object? lastError;
  for (final ip in ips) {
    try {
      final socket = await Socket.connect(
        ip,
        443,
        timeout: const Duration(seconds: 10),
      );
      final SecureSocket secure;
      try {
        secure = await SecureSocket.secure(
          socket,
          host: host,
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        socket.destroy();
        rethrow;
      }
      try {
        final req = StringBuffer()
          ..write(
            '$method ${uri.path}${uri.hasQuery ? '?${uri.query}' : ''} HTTP/1.1\r\n',
          )
          ..write('Host: $host\r\n');
        headers?.forEach((k, v) => req.write('$k: $v\r\n'));
        if (body != null) {
          req.write('Content-Length: ${utf8.encode(body).length}\r\n');
        }
        req
          ..write('Accept-Encoding: identity\r\n')
          ..write('Connection: close\r\n')
          ..write('\r\n');
        if (body != null) req.write(body);
        secure.write(req.toString());
        await secure.flush();
        final bytes = await secure
            .fold<List<int>>(<int>[], (prev, el) => prev..addAll(el))
            .timeout(const Duration(seconds: 30));
        return parseHttpResponse(bytes);
      } finally {
        secure.destroy();
      }
    } catch (e) {
      lastError = e;
    }
  }
  throw lastError ?? const SocketException('DoH: tidak ada IP yang bisa dipakai');
}

/// Resolve host lewat DNS-over-HTTPS (JSON API). Kembalikan daftar IPv4.
/// Publik agar bisa diuji langsung (tool/test_doh.dart).
Future<List<String>> resolveIpViaDoh(String host, {http.Client? client}) async {
  const providers = [
    'https://dns.google/resolve',
    'https://cloudflare-dns.com/dns-query',
  ];
  for (final base in providers) {
    try {
      final uri = Uri.parse('$base?name=$host&type=A');
      final res = await (client == null
              ? http.get(uri, headers: {'Accept': 'application/dns-json'})
              : client.get(uri, headers: {'Accept': 'application/dns-json'}))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) continue;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final answers = (data['Answer'] as List?) ?? const [];
      final ips = <String>[];
      for (final a in answers) {
        final m = a as Map<String, dynamic>;
        final ip = m['data'] as String?;
        if (m['type'] == 1 && ip != null && ip.isNotEmpty) ips.add(ip);
      }
      if (ips.isNotEmpty) return ips;
    } catch (_) {
      // Coba provider DoH berikutnya.
    }
  }
  throw const SocketException('DoH: tidak bisa me-resolve host');
}

/// Urai respons HTTP/1.1 mentah (status + header + body; dukung chunked).
/// Publik agar bisa diuji langsung (tool/test_doh.dart).
({int statusCode, String body}) parseHttpResponse(List<int> bytes) {
  var split = -1;
  for (var i = 0; i + 3 < bytes.length; i++) {
    if (bytes[i] == 13 &&
        bytes[i + 1] == 10 &&
        bytes[i + 2] == 13 &&
        bytes[i + 3] == 10) {
      split = i;
      break;
    }
  }
  if (split < 0) throw const FormatException('Respons HTTP tanpa header');
  final headerText = utf8.decode(bytes.sublist(0, split));
  var bodyBytes = bytes.sublist(split + 4);
  final lines = headerText.split('\r\n');
  final parts = lines.first.split(' ');
  final statusCode = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final headers = <String, String>{};
  for (final line in lines.skip(1)) {
    final idx = line.indexOf(':');
    if (idx > 0) {
      headers[line.substring(0, idx).trim().toLowerCase()] =
          line.substring(idx + 1).trim();
    }
  }
  if ((headers['transfer-encoding'] ?? '').contains('chunked')) {
    bodyBytes = _decodeChunked(bodyBytes);
  } else if (headers.containsKey('content-length')) {
    final len = int.tryParse(headers['content-length']!) ?? bodyBytes.length;
    if (bodyBytes.length > len) bodyBytes = bodyBytes.sublist(0, len);
  }
  return (statusCode: statusCode, body: utf8.decode(bodyBytes));
}

List<int> _decodeChunked(List<int> data) {
  final out = <int>[];
  var i = 0;
  while (i < data.length) {
    var eol = -1;
    for (var j = i; j + 1 < data.length; j++) {
      if (data[j] == 13 && data[j + 1] == 10) {
        eol = j;
        break;
      }
    }
    if (eol < 0) break;
    final sizeStr =
        utf8.decode(data.sublist(i, eol)).trim().split(';').first.trim();
    final size = int.tryParse(sizeStr, radix: 16);
    if (size == null) break;
    i = eol + 2;
    if (size == 0) break;
    if (i + size > data.length) break;
    out.addAll(data.sublist(i, i + size));
    i += size + 2; // lewati CRLF penutup chunk
  }
  return out;
}
