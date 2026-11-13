import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';

enum ScanSource { scanner, camera, gallery }

class ScanSession {
  const ScanSession({required this.paths, required this.source});
  final List<String> paths;
  final ScanSource source;
}

class ScanSessionNotifier extends Notifier<ScanSession?> {
  @override
  ScanSession? build() => null;
  void set(ScanSession s) => state = s;
}

final scanSessionProvider = NotifierProvider<ScanSessionNotifier, ScanSession?>(ScanSessionNotifier.new);

String _toFilePath(String p) => p.startsWith('file:') ? Uri.parse(p).toFilePath() : p;

Future<List<String>> _scanWithDocumentScanner() async {
  final scanner = DocumentScanner(
    options: DocumentScannerOptions(
      mode: ScannerMode.full,
      pageLimit: 5,
      isGalleryImport: true,
    ),
  );
  try {
    final result = await scanner.scanDocument();
    final dynamic images = result.images;
    if (images is List) return images.map((e) => _toFilePath(e.toString())).toList();
    return [];
  } finally {
    await scanner.close();
  }
}

Future<List<String>> _pickWithPicker(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 2400,
    maxHeight: 2400,
    imageQuality: 92,
  );
  return file == null ? [] : [file.path];
}

/// Starts a scan. [push] false is used by "Scan again" on the review screen.
Future<void> startScan(BuildContext context, WidgetRef ref, ScanSource source, {bool push = true}) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  try {
    final paths = switch (source) {
      ScanSource.scanner => await _scanWithDocumentScanner(),
      ScanSource.camera => await _pickWithPicker(ImageSource.camera),
      ScanSource.gallery => await _pickWithPicker(ImageSource.gallery),
    };
    if (paths.isEmpty) return; // cancelled
    for (final p in paths) {
      if (await File(p).length() > AppConfig.maxImageBytes) {
        messenger.showSnackBar(const SnackBar(content: Text('An image is too large (max 15 MB).')));
        return;
      }
    }
    ref.read(scanSessionProvider.notifier).set(ScanSession(paths: paths, source: source));
    if (push) router.push('/review');
  } catch (_) {
    messenger.showSnackBar(SnackBar(
      content: Text(source == ScanSource.scanner
          ? 'The document scanner is unavailable right now. Try "Use plain camera" or upload an image.'
          : 'Could not open the camera or gallery. Check app permissions and try again.'),
    ));
  }
}
