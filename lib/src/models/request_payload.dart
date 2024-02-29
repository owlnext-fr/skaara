import 'package:skaara/src/enums/methods.dart';
import 'package:skaara/src/enums/request_type.dart';
import 'package:skaara/src/enums/response_type.dart';

class RequestPayload {
  late String path;

  Methods method = Methods.GET;
  Map<String, dynamic> query = {};
  dynamic data;
  Map<String, dynamic> headers = {};
  RequestType requestType = RequestType.JSON;
  ResponseType responseType = ResponseType.JSON;

  RequestPayload({
    required this.path,
    this.method = Methods.GET,
    this.query = const {},
    this.data,
    this.headers = const {},
    this.requestType = RequestType.JSON,
    this.responseType = ResponseType.JSON,
  });
}
