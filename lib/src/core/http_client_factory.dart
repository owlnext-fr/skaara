import 'package:logger/logger.dart';
import 'package:skaara/src/configuration.dart';
import 'package:skaara/src/core/impl/service_factory_interface.dart';
import 'package:skaara/src/http_client.dart';

class HttpClientFactory implements ServiceFactoryInterface<HttpClient> {
  @override
  Future<HttpClient> getInstance(
      {required Configuration configuration, Logger? logger}) async {
    logger?.i('Building HttpClient...');

    return Future.value(HttpClient());
  }
}
