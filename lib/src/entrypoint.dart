import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:skaara/src/configuration.dart';
import 'package:skaara/src/core/database_factory.dart';
import 'package:skaara/src/core/http_client_factory.dart';
import 'package:skaara/src/core/logger_factory.dart';
import 'package:skaara/src/database.dart';
import 'package:skaara/src/enums/request_type.dart';
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
    options.method = requestPayload.method.toString();
    String url = _configuration.baseUrl + requestPayload.path;

    // preparing data
    dynamic finalData;

    switch (requestPayload.requestType) {
      case RequestType.JSON_LD:
      case RequestType.JSON:
        finalData = jsonEncode(requestPayload.data);
        break;
      case RequestType.MULTIPART:
        Map<String, dynamic> data = requestPayload.data;
        List<FilePart> fileParts = [];

        data.forEach((key, value) {
          if (value is FilePart) {
            fileParts.add(value);
            data.remove(key);
          }
        });

        int fileNumbers = fileParts.length;

        if (fileNumbers > 0) {
          if (fileNumbers == 1) {
            var file = MultipartFile.fromFile(fileParts[0].path,
                filename: fileParts[0].name);

            data.addAll({
              "file": file,
            });
          } else {
            List<MultipartFile> files = [];
            for (var filePart in fileParts) {
              var file = await MultipartFile.fromFile(filePart.path,
                  filename: filePart.name);
              files.add(file);
            }

            data.addAll({
              "files": files,
            });
          }
        }

        break;
      default:
        finalData = requestPayload.data;
    }

    // preparing headers
    Map<String, dynamic> headers = requestPayload.headers;

    return await _httpClient.instance
        .request(url, queryParameters: requestPayload.query, options: options);
  }
}
