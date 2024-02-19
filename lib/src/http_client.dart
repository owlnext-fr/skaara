// ignore_for_file: unused_field

import 'package:dio/dio.dart';

class HttpClient {
  late Dio _dio;

  HttpClient() {
    _dio = Dio();
  }

  Dio get instance => _dio;
}
