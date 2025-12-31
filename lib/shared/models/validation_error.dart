// ValidationError for configuration validation failures.

class ValidationError {
  const ValidationError(this.message, {this.field});
  final String message;
  final String? field;

  @override
  String toString() => field != null
      ? "ValidationError($field: $message)"
      : "ValidationError($message)";
}
