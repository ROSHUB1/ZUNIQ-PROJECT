import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/errors/app_exception.dart';

class OcrBlock {
  const OcrBlock({required this.text, required this.box, required this.lines});
  final String text;
  final Rect box;
  final List<String> lines;
}

class OcrResult {
  const OcrResult({required this.text, required this.blocks});
  final String text;
  final List<OcrBlock> blocks;
}

/// On-device OCR (Google ML Kit, Latin script). Blocks keep bounding boxes for later source highlighting.
class OcrService {
  Future<OcrResult> recognize(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final r = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      return OcrResult(
        text: r.text,
        blocks: [
          for (final b in r.blocks)
            OcrBlock(text: b.text, box: b.boundingBox, lines: [for (final l in b.lines) l.text]),
        ],
      );
    } catch (_) {
      throw const AppException('Could not read text from this image. Try a clearer, well-lit photo.');
    } finally {
      await recognizer.close();
    }
  }
}

final ocrServiceProvider = Provider<OcrService>((ref) => OcrService());
