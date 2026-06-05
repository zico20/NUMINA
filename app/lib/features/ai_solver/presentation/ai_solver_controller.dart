import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/failures.dart';
import '../data/ai_solver_api.dart';
import '../domain/solve_result.dart';

class AiSolverState {
  final File? image;
  final bool loading;
  final SolveResult? result;
  final String? error;
  final SolveMode mode;

  const AiSolverState({
    this.image,
    this.loading = false,
    this.result,
    this.error,
    this.mode = SolveMode.quick,
  });

  AiSolverState copyWith({
    File? image,
    bool? loading,
    SolveResult? result,
    String? error,
    SolveMode? mode,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return AiSolverState(
      image: image ?? this.image,
      loading: loading ?? this.loading,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      mode: mode ?? this.mode,
    );
  }
}

class AiSolverController extends StateNotifier<AiSolverState> {
  AiSolverController(this._api) : super(const AiSolverState());
  final AiSolverApi _api;
  final ImagePicker _picker = ImagePicker();

  /// Pick from the system gallery only — used when the user taps the
  /// gallery button in the Framing screen. Live camera capture goes
  /// through the in-app camera path and calls [setImage] directly.
  Future<File?> pickFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2400,
    );
    if (x == null) return null;
    final file = File(x.path);
    state = state.copyWith(
      image: file,
      clearResult: true,
      clearError: true,
    );
    return file;
  }

  void setMode(SolveMode m) => state = state.copyWith(mode: m);

  /// Inject an already-captured image (used by the in-app camera screen).
  Future<void> setImage(File file) async {
    state = state.copyWith(image: file, clearResult: true, clearError: true);
  }

  Future<void> solve(String langCode) async {
    final img = state.image;
    if (img == null) return;
    state = state.copyWith(loading: true, clearError: true, clearResult: true);
    try {
      // Always request `detailed` so the Solution screen can offer a
      // client-side Quick/Step-by-step toggle without an extra API call.
      // Roughly +200 output tokens per request — small price for the UX.
      final result = await _api.solveImage(
        imageFile: img,
        mode: SolveMode.detailed,
        langCode: langCode,
      );
      state = state.copyWith(loading: false, result: result);
    } on Failure catch (f) {
      state = state.copyWith(loading: false, error: f.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final aiSolverControllerProvider =
    StateNotifierProvider<AiSolverController, AiSolverState>((ref) {
  return AiSolverController(ref.watch(aiSolverApiProvider));
});
