import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import '../../core/theme/app_colors.dart';

class StudioCropperModal extends StatefulWidget {
  final Uint8List image;
  const StudioCropperModal({super.key, required this.image});

  @override
  State<StudioCropperModal> createState() => _StudioCropperModalState();
}

class _StudioCropperModalState extends State<StudioCropperModal> {
  final _controller = CropController();
  bool _isCropping = false;
  bool _hasPopped = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(2))),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCEL', style: TextStyle(color: AppColors.slateMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                ),
                const Text('STUDIO CROP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.studioIndigo, letterSpacing: 1.5)),
                TextButton(
                  onPressed: () {
                    if (_isCropping) return;
                    setState(() => _isCropping = true);
                    _controller.crop();
                  },
                  child: _isCropping 
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.studioIndigo))
                    : const Text('APPLY', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                ),
              ],
            ),
          ),

          // Cropper Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
              ),
              child: Crop(
                image: widget.image,
                controller: _controller,
                onCropped: (result) {
                  if (!_hasPopped) {
                    if (result is CropSuccess) {
                      _hasPopped = true;
                      Future.microtask(() {
                        if (mounted) Navigator.pop(context, result.croppedImage);
                      });
                    } else if (result is CropFailure) {
                      setState(() => _isCropping = false);
                      // Optional: handle failure
                    }
                  }
                },
                aspectRatio: 1 / 1,
                withCircleUi: false,
                baseColor: isDark ? Colors.black : Colors.white,
                maskColor: isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                radius: 20,
                interactive: true,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          Text('Adjust your masterpiece to fit the frame.', 
            style: TextStyle(color: AppColors.slateMuted, fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
