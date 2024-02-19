import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skaara/skaara.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'includes/fake_path_provider_platform.dart';

void main() async {
  // This is required to initialize the PathProviderPlatform
  WidgetsFlutterBinding.ensureInitialized();

  // This is required to override the default PathProviderPlatform for testing
  PathProviderPlatform.instance = FakePathProviderPlatform();

  // This is required to create a Skaara instance
  Skaara skaara = await Skaara.create(enableLogging: true);

  test('create skaara instance', () async {
    expect(skaara, isNotNull);
    expect(skaara.configuration.enableLogging, true);
    expect(skaara.database, isNotNull);
    expect(skaara.logger, isNotNull);
  });
}
