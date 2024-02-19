import 'package:hive/hive.dart';

class Database {
  late LazyBox _syncBox;
  late LazyBox _reqBox;

  Database({required LazyBox syncBox, required LazyBox reqBox}) {
    _syncBox = syncBox;
    _reqBox = reqBox;
  }

  LazyBox get syncBox => _syncBox;
  LazyBox get reqBox => _reqBox;
}
