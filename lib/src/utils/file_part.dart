import 'package:universal_io/io.dart';

class FilePart {
  final String name;
  final String path;

  FilePart({
    required this.name,
    required this.path,
  });

  static FilePart fromPath(String path) {
    File file = File(path);
    return fromFile(file);
  }

  static FilePart fromFile(File file) {
    return FilePart(name: file.uri.pathSegments.last, path: file.path);
  }
}
