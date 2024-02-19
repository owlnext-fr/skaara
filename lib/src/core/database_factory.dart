import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skaara/src/configuration.dart';
import 'package:skaara/src/core/impl/service_factory_interface.dart';
import 'package:skaara/src/database.dart';

class DatabaseFactory implements ServiceFactoryInterface<Database> {
  static String _db_dir = '/assets/skaara_db';

  @override
  Future<Database> getInstance(
      {required Configuration configuration, Logger? logger}) async {
    logger?.i('Generating database directory...');
    final dbDir = await generateDatabaseDirectory();
    logger?.i(' - Database directory: $dbDir');

    logger?.i('Initializing Hive...');
    Hive.init(dbDir);

    logger?.i('Opening sync database...');
    final syncDatabase = await Hive.openLazyBox(configuration.syncDatabaseName);
    logger?.i('Opening req database...');
    final reqDatabase = await Hive.openLazyBox(configuration.reqDatabaseName);

    return Future.value(Database(syncBox: syncDatabase, reqBox: reqDatabase));
  }

  Future<String> generateDatabaseDirectory() async {
    var path = _db_dir;

    if (false == kIsWeb) {
      var appDocDir = await getApplicationDocumentsDirectory();
      path = appDocDir.path;
    }

    return path;
  }
}
