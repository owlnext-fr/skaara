import 'package:logger/logger.dart';
import 'package:skaara/src/configuration.dart';
import 'package:skaara/src/core/database_factory.dart';
import 'package:skaara/src/core/logger_factory.dart';
import 'package:skaara/src/database.dart';

class Skaara {
  late Configuration _configuration;
  late Database _database;
  late Logger _logger;

  Skaara._create({
    required Configuration configuration,
    required Database database,
    required Logger logger,
  }) {
    _configuration = configuration;
    _database = database;
    _logger = logger;
  }

  static Future<Skaara> create({
    bool enableLogging = false,
  }) async {
    // configuration
    final configuration = Configuration(enableLogging: enableLogging);

    // ensure service initialization
    final logger =
        await LoggerFactory().getInstance(configuration: configuration);

    logger.i('Logger initialized !');

    final database = await DatabaseFactory()
        .getInstance(configuration: configuration, logger: logger);

    // create instance
    logger.i('Creating Skaara instance...');
    return Skaara._create(
      configuration: configuration,
      database: database,
      logger: logger,
    );
  }

  Logger get logger => _logger;
  Configuration get configuration => _configuration;
  Database get database => _database;

  int addOne(int value) {
    logger.i('Adding one to $value');
    return value + 1;
  }
}
