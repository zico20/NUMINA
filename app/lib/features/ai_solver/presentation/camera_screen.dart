import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../domain/solve_result.dart';
import 'ai_solver_controller.dart';
import 'solution_screen.dart';

/// In-app camera Framing → Analyzing flow. Replaces the old
/// "open native camera + cropper" pipeline.
///
/// Flow:
///   1. [Stage.framing] — live preview with corner brackets, a hint card,
///      a Quick/Detailed mode toggle and a big capture button.
///   2. [Stage.analyzing] — full-screen overlay over the captured image
///      with a moving scan line + spinner + sparkle while the backend
///      runs.
///   3. On completion → push [SolutionScreen] with the result.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

enum _Stage { framing, analyzing }

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  bool _initializing = true;
  String? _initError;
  _Stage _stage = _Stage.framing;
  File? _capturedFile;
  bool _flashOn = false;
  SolveMode _mode = SolveMode.quick;

  late final AnimationController _scanCtl;

  @override
  void initState() {
    super.initState();
    _scanCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = e.toString();
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _scanCtl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final c = _controller;
    if (c == null) return;
    try {
      final next = !_flashOn;
      await c.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _flashOn = next);
    } catch (_) {}
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      final pic = await c.takePicture();
      _capturedFile = File(pic.path);
      _startSolve();
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2400,
    );
    if (x == null) return;
    _capturedFile = File(x.path);
    _startSolve();
  }

  /// Hand the captured image to the controller, switch to analyzing,
  /// then push the Solution screen once the backend returns.
  Future<void> _startSolve() async {
    final ctl = ref.read(aiSolverControllerProvider.notifier);
    final lang = Localizations.localeOf(context).languageCode;
    setState(() => _stage = _Stage.analyzing);

    // Push the captured file into controller state without going through
    // the picker — we already have it.
    ctl.setMode(_mode);
    await ctl.setImage(_capturedFile!);
    await ctl.solve(lang);

    if (!mounted) return;
    final state = ref.read(aiSolverControllerProvider);
    if (state.error != null || state.result == null) {
      // Roll back to framing so user can retry.
      setState(() => _stage = _Stage.framing);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? 'Solve failed')),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SolutionScreen(result: state.result!)),
    );
  }

  void _retry() {
    setState(() {
      _capturedFile = null;
      _stage = _Stage.framing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview / captured image
          if (_initializing)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_initError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Camera unavailable: $_initError',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            )
          else if (_stage == _Stage.analyzing && _capturedFile != null)
            Image.file(_capturedFile!, fit: BoxFit.cover)
          else if (_controller != null && _controller!.value.isInitialized)
            _CameraPreviewBox(controller: _controller!),

          // Subtle vignette
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.0,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
          ),

          if (_stage == _Stage.framing) ..._framingOverlay(),
          if (_stage == _Stage.analyzing) ..._analyzingOverlay(),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    _AiVisionBadge(),
                    const Spacer(),
                    _GlassIconButton(
                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                      onPressed: _stage == _Stage.framing ? _toggleFlash : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Framing overlay (corners + hint + bottom controls) ──────────────
  List<Widget> _framingOverlay() {
    return [
      // Hint card
      Positioned(
        top: 110,
        left: 20,
        right: 20,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Frame the equation',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Keep the equation inside the frame, avoid glare',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Frame corners
      const Positioned.fill(
        child: IgnorePointer(child: _FrameCorners()),
      ),

      // Bottom controls
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                // Quick / Detailed toggle (placed above the row of buttons)
                _ModePill(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SquareGlassButton(
                      icon: Icons.photo_library_outlined,
                      onPressed: _pickFromGallery,
                    ),
                    _CaptureButton(onPressed: _capture),
                    _SquareGlassButton(
                      icon: Icons.refresh,
                      onPressed: _retry,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  // ─── Analyzing overlay (scan line + spinner + sparkle) ───────────────
  List<Widget> _analyzingOverlay() {
    const accent = Color(0xFF3FE09A);
    return [
      // Dim layer over the captured image
      Container(color: Colors.black.withValues(alpha: 0.55)),

      // Scan line
      AnimatedBuilder(
        animation: _scanCtl,
        builder: (_, _) {
          final h = MediaQuery.of(context).size.height;
          final top = 0.20 * h + (0.45 * h) * Curves.easeInOut.transform(_scanCtl.value);
          return Positioned(
            top: top,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    accent.withValues(alpha: 0.40),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Center spinner + sparkle + label
      Positioned.fill(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accent.withValues(alpha: 0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 76,
                      height: 76,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                    const Icon(Icons.auto_awesome, color: accent, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Analyzing…',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reading the equation as LaTeX',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

// ─── Helpers / sub-widgets ────────────────────────────────────────────

/// Live camera preview cropped to fill its parent.
class _CameraPreviewBox extends StatelessWidget {
  const _CameraPreviewBox({required this.controller});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * controller.value.aspectRatio;
    return Transform.scale(
      scale: scale < 1 ? 1 / scale : scale,
      child: Center(child: CameraPreview(controller)),
    );
  }
}

/// 4 green L-shaped corner brackets framing the central capture area.
class _FrameCorners extends StatelessWidget {
  const _FrameCorners();

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF3FE09A);
    Widget corner({required AlignmentGeometry align, required BorderRadius radius, required Border border}) {
      return Align(
        alignment: align,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: border,
            borderRadius: radius,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 180, 28, 240),
      child: Stack(
        children: [
          corner(
            align: Alignment.topLeft,
            radius: const BorderRadius.only(topLeft: Radius.circular(12)),
            border: const Border(
              top: BorderSide(color: accent, width: 3),
              left: BorderSide(color: accent, width: 3),
            ),
          ),
          corner(
            align: Alignment.topRight,
            radius: const BorderRadius.only(topRight: Radius.circular(12)),
            border: const Border(
              top: BorderSide(color: accent, width: 3),
              right: BorderSide(color: accent, width: 3),
            ),
          ),
          corner(
            align: Alignment.bottomLeft,
            radius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
            border: const Border(
              bottom: BorderSide(color: accent, width: 3),
              left: BorderSide(color: accent, width: 3),
            ),
          ),
          corner(
            align: Alignment.bottomRight,
            radius: const BorderRadius.only(bottomRight: Radius.circular(12)),
            border: const Border(
              bottom: BorderSide(color: accent, width: 3),
              right: BorderSide(color: accent, width: 3),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _SquareGlassButton extends StatelessWidget {
  const _SquareGlassButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF3FE09A);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.40),
              blurRadius: 30,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: accent,
          ),
          child: const Icon(Icons.auto_awesome, color: Color(0xFF03130C), size: 28),
        ),
      ),
    );
  }
}

class _AiVisionBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF3FE09A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: accent, size: 14),
          const SizedBox(width: 6),
          Text(
            'AI Vision',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.mode, required this.onChanged});
  final SolveMode mode;
  final ValueChanged<SolveMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(SolveMode.quick, 'Quick'),
          _seg(SolveMode.detailed, 'Detailed'),
        ],
      ),
    );
  }

  Widget _seg(SolveMode value, String label) {
    final selected = mode == value;
    const accent = Color(0xFF3FE09A);
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: selected ? const Color(0xFF03130C) : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

// Minor helper to silence the unused-element warning if NuminaPalette isn't
// referenced (our screen uses hardcoded colors to match the dark mock).
// ignore: unused_element
typedef _NuminaPaletteUse = NuminaPalette;
