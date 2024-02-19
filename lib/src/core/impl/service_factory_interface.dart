import 'package:logger/logger.dart';
import 'package:skaara/src/configuration.dart';

abstract class ServiceFactoryInterface<T> {
  Future<T> getInstance({
    required Configuration configuration,
    Logger? logger,
  });
}
