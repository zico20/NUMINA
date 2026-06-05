import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_config.dart';
import '../../../core/errors/failures.dart';
import '../domain/solve_result.dart';

/// Talks to our backend proxy (NEVER directly to OpenAI from the app).
/// Backend exposes:  POST {BACKEND_URL}/solve  with JSON body
///   { imageBase64: "...", mode: "quick" | "detailed", lang: "en" | "ar" }
class AiSolverApi {
  AiSolverApi(this._client);
  final http.Client _client;

  Future<SolveResult> solveImage({
    required File imageFile,
    required SolveMode mode,
    required String langCode,
  }) async {
    if (!AppConfig.hasBackend) {
      throw const ApiFailure('Backend URL not configured');
    }
    final bytes = await imageFile.readAsBytes();
    final body = jsonEncode({
      'imageBase64': base64Encode(bytes),
      'mode': mode.name,
      'lang': langCode,
    });
    try {
      final res = await _client
          .post(
            Uri.parse('${AppConfig.backendUrl}/solve'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode != 200) {
        throw ApiFailure(
          'Server returned ${res.statusCode}',
          statusCode: res.statusCode,
        );
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return SolveResult.fromJson(json);
    } on SocketException {
      throw const NetworkFailure('No internet connection');
    } on FormatException {
      throw const ParseFailure('Invalid response from server');
    }
  }
}

final aiSolverApiProvider = Provider<AiSolverApi>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return AiSolverApi(client);
});
