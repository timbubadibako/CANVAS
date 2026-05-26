import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import 'nutrition_review_screen.dart';

class AIScannerScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const AIScannerScreen({super.key, this.onBackToHome});

  @override
  State<AIScannerScreen> createState() => _AIScannerScreenState();
}

class _AIScannerScreenState extends State<AIScannerScreen> with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  
  bool _isCameraReady = false;
  bool _hasCameraError = false;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  int _captureStep = 0; 

  @override
  void initState() {
    super.initState();
    _initCamera();
    _scanController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(CurvedAnimation(parent: _scanController, curve: Curves.easeInOut));
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(_cameras![0], ResolutionPreset.medium, enableAudio: false);
        await _controller!.initialize();
        if (!mounted) return;
        setState(() => _isCameraReady = true);
      } else { setState(() => _hasCameraError = true); }
    } catch (e) { setState(() => _hasCameraError = true); }
  }

  void _handleCapture() {
    if (_captureStep < 2) {
      setState(() => _captureStep++);
      final String angle = _captureStep == 1 ? "30°" : "60°";
      StudioToast.show(context, "CAPTURE FROM $angle", icon: LucideIcons.camera);
    } else {
      _startArtisticPipeline();
    }
  }

  void _startArtisticPipeline() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _captureStep = 0; // Reset scanner state for next use
      });
      
      // Navigasi ke Review Screen dengan callback kembali ke Dashboard
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionReviewScreen(
            initialName: "Mediterranean Plate",
            initialKcal: 520,
            initialProtein: 35.5,
            initialCarbs: 45.0,
            initialFat: 12.5,
            initialWeight: 450,
            onSaveCompleted: widget.onBackToHome, // Trigger kembali ke Dashboard
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraReady && _controller != null)
            SizedBox.expand(child: CameraPreview(_controller!))
          else
            _buildArtisticFallback(),

          if (!_isProcessing) _buildOverlay(context),

          if (_isProcessing) _buildProcessingOverlay(),

          Positioned(
            top: 60, left: 24, right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRoundBtn(LucideIcons.arrowLeft, widget.onBackToHome ?? () => Navigator.pop(context)),
                _buildStatusIndicator(context),
                _buildRoundBtn(_isFlashOn ? LucideIcons.zap : LucideIcons.zapOff, () {}, isActive: _isFlashOn),
              ],
            ),
          ),

          if (!_isProcessing) Positioned(
            bottom: 60, left: 0, right: 0,
            child: Column(
              children: [
                _buildCaptureSteps(),
                const SizedBox(height: 24),
                _buildShutterButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 100, width: 100,
              child: CircularProgressIndicator(color: AppColors.studioIndigo, strokeWidth: 2),
            ),
            const SizedBox(height: 40),
            Text('APPLYING ARTISTIC BRUSH...', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.studioIndigo, letterSpacing: 2)),
            const SizedBox(height: 12),
            const Text('Converting meal into a studio masterpiece', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isDone = index < _captureStep;
        final bool isCurrent = index == _captureStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4, width: isCurrent ? 24 : 12,
          decoration: BoxDecoration(color: isDone || isCurrent ? AppColors.studioIndigo : Colors.white24, borderRadius: BorderRadius.circular(2)),
        );
      }),
    );
  }

  Widget _buildArtisticFallback() {
    return Container(
      width: double.infinity, height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.deepSlate,
        image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop'), fit: BoxFit.cover, opacity: 0.5),
      ),
      child: _hasCameraError ? const Center(child: Icon(LucideIcons.cameraOff, color: Colors.white24, size: 48)) : null,
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.studioIndigo.withValues(alpha: 0.3))),
      child: Row(children: [
        const CircleAvatar(radius: 3, backgroundColor: AppColors.studioIndigo),
        const SizedBox(width: 8),
        Text('STUDIO AI ACTIVE', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9, letterSpacing: 1.2, color: Colors.white)),
      ]),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _handleCapture,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 84, width: 84, padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 4)),
        child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(_captureStep == 0 ? LucideIcons.scan : LucideIcons.camera, color: AppColors.deepSlate, size: 28)),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Center(
      child: Container(
        width: 280, height: 280,
        decoration: BoxDecoration(border: Border.all(color: AppColors.studioIndigo.withValues(alpha: 0.4), width: 1.5), borderRadius: const BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(40), bottomLeft: Radius.circular(30), bottomRight: Radius.circular(70))),
        child: Stack(children: [
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(top: 280 * _scanAnimation.value, left: 20, right: 20, child: Container(height: 2, decoration: BoxDecoration(color: AppColors.studioIndigo, boxShadow: [BoxShadow(color: AppColors.studioIndigo.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)])));
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildRoundBtn(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 300), height: 48, width: 48, decoration: BoxDecoration(color: isActive ? AppColors.studioIndigo.withValues(alpha: 0.2) : Colors.black26, borderRadius: BorderRadius.circular(16), border: Border.all(color: isActive ? AppColors.studioIndigo : Colors.white10)), child: Icon(icon, color: isActive ? AppColors.studioIndigo : Colors.white, size: 20)),
    );
  }
}
