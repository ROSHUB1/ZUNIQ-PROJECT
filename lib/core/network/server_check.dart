import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Plain-language connectivity check for the ZUNIQ API (shown in Settings).
Future<String> checkServer() async {
  if (!AppConfig.isAiConfigured) {
    return 'This build has no server address (ZUNIQ_API_URL is empty).';
  }
  final uri = Uri.tryParse('${AppConfig.apiBase}/api/analyze');
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return 'The server address looks invalid:\n${AppConfig.apiBase}';
  }
  try {
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    final body = res.body.length > 120 ? res.body.substring(0, 120) : res.body;
    final ok = res.statusCode == 405;
    return '${ok ? 'Server reachable.' : 'The server answered, but not as expected.'}\n'
        'Host: ${uri.host}\nHTTP ${res.statusCode}\n$body';
  } on TimeoutException {
    return 'Timed out while reaching ${uri.host}.';
  } on SocketException catch (e) {
    return 'Cannot reach ${uri.host}.\n${e.message}';
  } catch (e) {
    return 'Error: ${e.runtimeType}\n$e';
  }
}
