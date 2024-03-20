import 'package:skaara/src/enums/methods.dart';

class ExceptionMessageFormatter {
  const ExceptionMessageFormatter();

  String format({
    required Methods method,
    required String url,
    int statusCode = 0,
    String? message,
  }) {
    return "[Skaara HTTP ${statusCode.toString()}] ${method.toShortString()} $url - $message";
  }
}
