// ignore_for_file: constant_identifier_names

enum Methods {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
  HEAD,
  OPTIONS,
  CONNECT,
  TRACE,
}

extension MethodsExtension on Methods {
  String toShortString() {
    return toString().split('.').last;
  }
}
