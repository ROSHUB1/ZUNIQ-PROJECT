import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../analysis/domain/analysis_result.dart';

/// Talks to the Supabase Edge Function. The LLM key never lives in the app.
class AnalysisApi {
  Future<AnalysisResult> analyze({
    required String text,
    required String languageCode,
    required String languageName,
  }) async {
    if (!AppConfig.isAiConfigured) {
      throw const AppException(
          'The AI service is not set up yet. Text extraction worked; add the API settings to enable explanations.');
    }
    try {
      final res = await http
          .post(
            Uri.parse('${AppConfig.apiBase}/api/analyze'),
            headers: {
              'Content-Type': 'application/json',
              if (AppConfig.apiKey.isNotEmpty) 'x-zuniq-key': AppConfig.apiKey,
            },
            body: jsonEncode({'text': text, 'language_code': languageCode, 'language_name': languageName}),
          )
          .timeout(const Duration(seconds: 130));
      if (res.statusCode != 200) {
        throw AppException('The AI service returned an error (${res.statusCode}). Please try again.');
      }
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is! Map) throw const AppException('The AI service sent an unexpected response.');
      return AnalysisResult.fromJson(Map<String, dynamic>.from(body));
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

final analysisApiProvider = Provider<AnalysisApi>((ref) => AnalysisApi());
