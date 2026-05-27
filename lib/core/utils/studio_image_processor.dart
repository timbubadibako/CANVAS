import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../presentation/widgets/studio_cropper_modal.dart';

class StudioImageProcessor {
  /// Alur Elit: Flutter Bottom Sheet Cropper -> Compress
  static Future<File?> processAvatar(BuildContext context, String inputPath) async {
    try {
      // 1. Baca file asal sebagai bytes
      final Uint8List inputBytes = await File(inputPath).readAsBytes();

      // 2. Munculkan Bottom Sheet Cropper (Opsi 2 - 100% Flutter)
      if (!context.mounted) return null;
      final Uint8List? croppedBytes = await showModalBottomSheet<Uint8List>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => StudioCropperModal(image: inputBytes),
      );

      if (croppedBytes == null) return null;

      // 3. Compression Stage agar ringan (Max 70% Quality)
      final dir = await getTemporaryDirectory();
      final targetPath = "${dir.absolute.path}/temp_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";
      
      final compressedData = await FlutterImageCompress.compressWithList(
        croppedBytes,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressedData);

      return resultFile;
    } catch (e) {
      return null;
    }
  }
}
