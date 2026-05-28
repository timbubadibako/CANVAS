import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../presentation/widgets/studio_cropper_modal.dart';

class StudioImageProcessor {
  /// Alur Elit: Flutter Bottom Sheet Cropper -> Standard Async Compress
  /// Catatan: FlutterImageCompress secara internal sudah berjalan di background thread native.
  static Future<File?> processAvatar(BuildContext context, String inputPath) async {
    try {
      print('[StudioImageProcessor] Starting avatar processing for: $inputPath');
      final Uint8List inputBytes = await File(inputPath).readAsBytes();

      if (!context.mounted) return null;
      print('[StudioImageProcessor] Opening StudioCropperModal...');
      final Uint8List? croppedBytes = await showModalBottomSheet<Uint8List>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => StudioCropperModal(image: inputBytes),
      );

      if (croppedBytes == null) {
        print('[StudioImageProcessor] Cropping cancelled by user.');
        return null;
      }

      print('[StudioImageProcessor] Cropping success. Starting compression...');

      // 3. Compression Stage (Jalan secara asinkron di level Native)
      final dir = await getTemporaryDirectory();
      final targetPath = "${dir.absolute.path}/temp_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final compressedData = await FlutterImageCompress.compressWithList(
        croppedBytes,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      print('[StudioImageProcessor] Compression finished. Size: ${compressedData.length} bytes');

      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressedData);
      print('[StudioImageProcessor] File saved successfully. Returning to Profile Screen.');

      return resultFile;
    } catch (e) {
      print('[StudioImageProcessor] FATAL ERROR during avatar processing: $e');
      return null;
    }
  }
}
