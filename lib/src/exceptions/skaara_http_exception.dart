import 'package:skaara/src/enums/methods.dart';

import 'skaara_exception.dart';

class SkaaraHttpException extends SkaaraException {
  final String url;
  final Methods method;
  final int statusCode;
  final dynamic statusMessage;

  SkaaraHttpException({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.statusMessage,
  }) : super(
            '[HTTP $statusCode] ${method.toShortString()} $url - ${statusMessage.toString()}');
}
