class SolveResult {
  /// True when the AI accepted the image as a math problem.
  final bool isMath;

  /// 0-100 self-assessed confidence from the model.
  final int confidence;

  /// Friendly refusal message when [isMath] is false.
  final String refusal;

  /// LaTeX of the extracted problem (empty when refused).
  final String latex;

  /// Final answer in LaTeX (empty when refused).
  final String answer;

  /// Step-by-step explanation (empty in quick mode or when refused).
  final List<SolveStep> steps;

  const SolveResult({
    required this.isMath,
    this.confidence = 0,
    this.refusal = '',
    this.latex = '',
    this.answer = '',
    this.steps = const [],
  });

  factory SolveResult.fromJson(Map<String, dynamic> json) {
    return SolveResult(
      isMath: json['isMath'] == true,
      confidence: (json['confidence'] is num) ? (json['confidence'] as num).toInt() : 0,
      refusal: (json['refusal'] ?? '') as String,
      latex: (json['latex'] ?? '') as String,
      answer: (json['answer'] ?? '') as String,
      steps: ((json['steps'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SolveStep.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'isMath': isMath,
        'confidence': confidence,
        'refusal': refusal,
        'latex': latex,
        'answer': answer,
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}

class SolveStep {
  final String description;
  final String latex;

  const SolveStep({required this.description, required this.latex});

  factory SolveStep.fromJson(Map<String, dynamic> j) => SolveStep(
        description: (j['description'] ?? '') as String,
        latex: (j['latex'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'latex': latex,
      };
}

enum SolveMode { quick, detailed }
