import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../presentation/widgets/studio_cropper_modal.dart';

/// Data class untuk passing ke Isolate
class _CompressParams {
  final Uint8List bytes;
  final int quality;
  _CompressParams(this.bytes, this.quality);
}

/// Fungsi top-level untuk Isolate (Heavy Lifting)
Future<Uint8List> _heavyCompress(Object params) async {
  final p = params as _CompressParams;
  return await FlutterImageCompress.compressWithList(
    p.bytes,
    quality: p.quality,
    format: CompressFormat.jpeg,
  );
}

class StudioImageProcessor {
  /// Alur Elit: Flutter Bottom Sheet Cropper -> Background Isolate Compress
  static Future<File?> processAvatar(BuildContext context, String inputPath) async {
    try {
      final Uint8List inputBytes = await File(inputPath).readAsBytes();

      if (!context.mounted) return null;
      final Uint8List? croppedBytes = await showModalBottomSheet<Uint8List>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => StudioCropperModal(image: inputBytes),
      );

      if (croppedBytes == null) return null;

      // 3. Compression Stage in BACKGROUND ISOLATE (Using compute)
      final dir = await getTemporaryDirectory();
      final targetPath = "${dir.absolute.path}/temp_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";

      print('[StudioImageProcessor] Offloading compression to background isolate...');
      final compressedData = await compute(_heavyCompress, _CompressParams(croppedBytes, 70));

      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressedData);

      return resultFile;
    } catch (e) {
      print('[StudioImageProcessor] Error: $e');
      return null;
    }
  }
}
