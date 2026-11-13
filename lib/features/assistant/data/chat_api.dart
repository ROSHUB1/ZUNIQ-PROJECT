import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';

class ChatApi {
  Future<({String reply, String? mood})> chat({
    required List<Map<String, String>> history,
    required String? context,
    required String languageCode,
    required String languageName,
  }) async {
    if (!AppConfig.isAiConfigured) {
      throw const AppException('The AI service is not set up yet, so I cannot answer right now.');
    }
    try {
      final res = await http
          .post(
            Uri.parse('${AppConfig.apiBase}/api/analyze'),
            headers: {
              'Content-Type': 'application/json',
              if (AppConfig.apiKey.isNotEmpty) 'x-zuniq-key': AppConfig.apiKey,
            },
            body: jsonEncode({
              'mode': 'chat',
              'messages': history,
              'context': context,
              'language_code': languageCode,
              'language_name': languageName,
            }),
          )
          .timeout(const Duration(seconds: 90));
      if (res.statusCode != 200) {
        throw AppException('The AI service returned an error (${res.statusCode}). Please try again.');
      }
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final reply = body is Map ? body['reply'] : null;
      if (reply is! String || reply.trim().isEmpty) {
        throw const AppException('The AI service sent an empty answer. Please try again.');
      }
      final mood = body['mood'];
      return (reply: reply.trim(), mood: mood is String ? mood : null);
    } on TimeoutException {
      throw const AppException('This is taking too long. Check your connection and try again.');
    } on SocketException catch (e) {
      throw AppException(
          'Could not reach the ZUNIQ server (${e.message}). Check your connection and the server address, then try again.');
    } on http.ClientException catch (e) {
      throw AppException('Could not reach the ZUNIQ server (${e.message}).');
    } on FormatException {
      throw const AppException('The AI service sent an unreadable response. Please try again.');
    }
  }
}

final chatApiProvider = Provider<ChatApi>((ref) => ChatApi());
