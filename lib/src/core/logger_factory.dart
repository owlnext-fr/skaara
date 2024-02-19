import 'package:logger/logger.dart';
import 'package:skaara/src/configuration.dart';
import 'package:skaara/src/core/impl/service_factory_interface.dart';

class LoggerFactory implements ServiceFactoryInterface<Logger> {
  @override
  Future<Logger> getInstance(
      {required Configuration configuration, Logger? logger}) {
    if (configuration.enableLogging) {
      return Future.value(Logger(
        printer: SimplePrinter(printTime: true),
        level: configuration.logLevel,
      ));
    }

    return Future.value(Logger(
      printer: SimplePrinter(),
      level: Level.error,
    ));
  }
}
