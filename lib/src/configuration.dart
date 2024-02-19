import 'package:logger/logger.dart';

class Configuration {
  // #region dynamic configuration
  bool enableLogging = false;
  // #endregion

  // #region static configuration
  final Level logLevel = Level.info;
  final String syncDatabaseName = 'skaara.db.sync';
  final String reqDatabaseName = 'skaara.db.req';
  // #endregion

  Configuration({
    this.enableLogging = false,
  });
}
