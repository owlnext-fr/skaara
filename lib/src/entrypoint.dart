import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:skaara/src/configuration.dart';
import 'package:skaara/src/core/database_factory.dart';
import 'package:skaara/src/core/http_client_factory.dart';
import 'package:skaara/src/core/logger_factory.dart';
import 'package:skaara/src/database.dart';
import 'package:skaara/src/enums/methods.dart';
import 'package:skaara/src/enums/request_type.dart';
import 'package:skaara/src/exceptions/skaara_http_exception.dart';
import 'package:skaara/src/http_client.dart';
import 'package:skaara/src/models/request_payload.dart';
import 'package:skaara/src/utils/file_part.dart';

class Skaara {
  // #region fields
  static Skaara? _instance;
  late Configuration _configuration;
  late Database _database;
  late Logger _logger;
  // ignore: unused_field
  late HttpClient _httpClient;
  // #endregion

  // #region constructor
  Skaara._create({
    required Configuration configuration,
    required Database database,
    required Logger logger,
    required HttpClient httpClient,
  }) {
    _configuration = configuration;
    _database = database;
    _logger = logger;
    _httpClient = httpClient;
  }
  // #endregion

  // #region singleton instance accessor
  static Future<Skaara> create({
    required String baseUrl,
    bool enableLogging = false,
  }) async {
    if (_instance != null) {
      _instance!.logger.i('Skaara instance already created !');
      return Future(() => _instance!);
    }

    // configuration
    final configuration =
        Configuration(baseUrl: baseUrl, enableLogging: enableLogging);

    // ensure service initialization
    final logger =
        await LoggerFactory().getInstance(configuration: configuration);

    logger.i('Logger initialized !');

    final database = await DatabaseFactory()
        .getInstance(configuration: configuration, logger: logger);

    logger.i('Database initialized !');

    final httpClient = await HttpClientFactory()
        .getInstance(configuration: configuration, logger: logger);

    logger.i('HttpClient initialized !');

    // create instance
    logger.i('Creating Skaara instance...');
    Skaara instance = Skaara._create(
      configuration: configuration,
      database: database,
      logger: logger,
      httpClient: httpClient,
    );

    _instance = instance;

    logger.i('Skaara instance created !');
    return Future(() => instance);
  }
  // #endregion

  // #region getters
  Logger get logger => _logger;
  Configuration get configuration => _configuration;
  Database get database => _database;
  // #endregion

  Future<dynamic> execute(RequestPayload requestPayload) async {
    // preparing options
    Options options = Options();

    // preparing http basics
    options.method = requestPayload.method.toShortString();
    String url = _configuration.baseUrl + requestPayload.path;

    // preparing data
    dynamic finalData;

    if (null != requestPayload.data) {
      switch (requestPayload.requestType) {
        case RequestType.JSON_LD:
        case RequestType.JSON:
          finalData = jsonEncode(requestPayload.data);
          break;
        case RequestType.MULTIPART:
          finalData = requestPayload.data;
          List<FilePart> fileParts = [];
          List<MultipartFile> finalFileParts = [];
          List<String> keysToDelete = [];

          for (var key in finalData.keys) {
            if (finalData[key] is FilePart) {
              fileParts.add(finalData[key]);
              keysToDelete.add(key);
            }
          }

          for (var key in keysToDelete) {
            finalData.remove(key);
          }

          for (var filePart in fileParts) {
            finalFileParts.add(await MultipartFile.fromFile(filePart.path,
                filename: filePart.name));
          }

          if (finalFileParts.isNotEmpty) {
            if (finalFileParts.length > 1) {
              finalData['files'] = finalFileParts;
            } else {
              finalData['file'] = finalFileParts.first;
            }
          }

          finalData = FormData.fromMap(finalData);

          break;

        case RequestType.URL_ENCODED:
          options.contentType = Headers.formUrlEncodedContentType;
          finalData = requestPayload.data;
          break;
        default:
          finalData = requestPayload.data;
      }
    }

    // preparing headers
    Map<String, dynamic> headers = requestPayload.headers;

    options.validateStatus = (status) {
      return true;
    };

    String? displayableData = finalData is FormData
        ? [finalData.fields.toString(), finalData.files.toString()].toString()
        : finalData.toString();

    _logger.i('URL: $url');
    _logger.i('Method: ${options.method}');
    _logger.i('Query: ${requestPayload.query}');
    _logger.i('Data: $displayableData');
    _logger.i('Headers: $headers');
    _logger.i('RequestType: ${requestPayload.requestType}');
    _logger.i('ResponseType: ${requestPayload.responseType}');

    var response = await _httpClient.instance.request(url,
        data: finalData,
        queryParameters: requestPayload.query,
        options: options);

    _logger.i('Status: ${response.statusCode}');
    _logger.i('Response: ${response.data}');

    if (response.statusCode! >= 400) {
      SkaaraHttpException ex = SkaaraHttpException(
          url: url,
          method: requestPayload.method,
          statusCode: response.statusCode ?? 0,
          statusMessage: response.data);

      _logger.e(ex);

      throw ex;
    }

    return response;
  }
}
