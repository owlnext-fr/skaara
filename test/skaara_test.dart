import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skaara/skaara.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:skaara/src/exceptions/exception_mapper.dart';

import 'includes/fake_path_provider_platform.dart';

// helper classes
class TestException implements Exception {
  final String message;

  TestException(this.message);

  @override
  String toString() {
    return message;
  }
}

void main() async {
  // This is required to initialize the PathProviderPlatform
  WidgetsFlutterBinding.ensureInitialized();

  // This is required to override the default PathProviderPlatform for testing
  PathProviderPlatform.instance = FakePathProviderPlatform();

  // This is required to create a Skaara instance
  Skaara skaara =
      await Skaara.create(enableLogging: false, baseUrl: '', exceptionMap: [
    ExceptionMap(
      voterFunction: (int statusCode) => statusCode == 404,
      factoryFunction: (String message) => TestException(message),
    ),
  ]);

  test('create skaara instance', () async {
    expect(skaara, isNotNull);
    expect(skaara.configuration, isNotNull);
    expect(skaara.database, isNotNull);
    expect(skaara.logger, isNotNull);
  });

  test('Try to get duplicate instance', () async {
    Skaara skaara2 = await Skaara.create(enableLogging: true, baseUrl: '');
    expect(skaara, equals(skaara2));
  });

  test('Execute simple GET request', () async {
    final response = await skaara.execute(
      RequestPayload(path: 'https://jsonplaceholder.typicode.com/posts/1'),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
  });

  test('Execute GET request with query params', () async {
    final response = await skaara.execute(
      RequestPayload(
        path: 'https://jsonplaceholder.typicode.com/posts/1',
        query: Map.fromEntries([const MapEntry('userId', '1')]),
      ),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
  });

  test('Execute simple POST request', () async {
    final response = await skaara.execute(
      RequestPayload(
        path: 'https://jsonplaceholder.typicode.com/posts',
        method: Methods.POST,
        data: {
          'title': 'foo',
          'body': 'bar',
          'userId': 1,
        },
      ),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 201);
    expect(response.data, isNotNull);
  });

  test('Execute POST request with multipart', () async {
    final response = await skaara.execute(
      RequestPayload(
          path: 'https://jsonplaceholder.typicode.com/posts',
          method: Methods.POST,
          data: {
            "title": "foo",
            'file': FilePart(name: 'test.txt', path: './.fvmrc')
          },
          requestType: RequestType.MULTIPART),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 201);
    expect(response.data, isNotNull);
  });

  test('Execute POST request with multipart multifiles', () async {
    final response = await skaara.execute(
      RequestPayload(
          path: 'https://jsonplaceholder.typicode.com/posts',
          method: Methods.POST,
          data: {
            "title": "foo",
            'files': [
              FilePart(name: 'test.txt', path: './.fvmrc'),
              FilePart(name: 'test.txt', path: './.fvmrc')
            ]
          },
          requestType: RequestType.MULTIPART),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 201);
    expect(response.data, isNotNull);
  });

  test('Execute simple POST request with URLencode', () async {
    final response = await skaara.execute(
      RequestPayload(
        path: 'https://jsonplaceholder.typicode.com/posts',
        method: Methods.POST,
        data: {
          'title': 'foo',
          'body': 'bar',
          'userId': 1,
        },
        requestType: RequestType.URL_ENCODED,
      ),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 201);
    expect(response.data, isNotNull);
  });

  test('Execute simple PUT request', () async {
    final response = await skaara.execute(
      RequestPayload(
        path: 'https://jsonplaceholder.typicode.com/posts/1',
        method: Methods.PUT,
        data: {
          'id': 1,
          'title': 'foo',
          'body': 'bar',
          'userId': 1,
        },
      ),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
  });

  test('Execute simple DELETE request', () async {
    final response = await skaara.execute(
      RequestPayload(
          path: 'https://jsonplaceholder.typicode.com/posts/1',
          method: Methods.DELETE),
    );
    expect(response, isNotNull);
    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
  });

  test('Handle exception on 404', () async {
    try {
      await skaara.execute(RequestPayload(
          path: 'https://jsonplaceholder.typicode.com/posts/404'));
      fail("A SkaaraHttpException should have been thrown");
    } catch (e) {
      expect(e, isInstanceOf<Exception>());
    }
  });

  test('Handle mapped exception on 404', () async {
    try {
      await skaara.execute(RequestPayload(
          path: 'https://jsonplaceholder.typicode.com/posts/404'));
      fail("A SkaaraHttpException should have been thrown");
    } catch (e) {
      expect(e, isInstanceOf<TestException>());
    }
  });
}
