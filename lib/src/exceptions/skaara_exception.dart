class SkaaraException implements Exception {
  final String message;

  SkaaraException(this.message);

  @override
  String toString() => message;
}
