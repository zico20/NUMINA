sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure(super.message, {this.statusCode});
}

class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

class CalculationFailure extends Failure {
  const CalculationFailure(super.message);
}
