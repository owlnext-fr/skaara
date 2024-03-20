import 'package:skaara/src/exceptions/skaara_exception.dart';

class ExceptionMapper {
  late final Map<int, ExceptionMap> _exceptionMap;

  ExceptionMapper() {
    _exceptionMap = {};
  }

  void add(Function(int) voterFunction, Function(String) factoryFunction) {
    int length = _exceptionMap.length;

    _exceptionMap.addEntries({
      MapEntry<int, ExceptionMap>(
        length,
        ExceptionMap(
          voterFunction: voterFunction,
          factoryFunction: factoryFunction,
        ),
      ),
    });
  }

  Exception getException(int code, String message) {
    for (var entry in _exceptionMap.entries) {
      ExceptionMap val = entry.value;

      if (true == val.voterFunction(code)) {
        return val.factoryFunction(message);
      }
    }

    return SkaaraException(message);
  }
}

class ExceptionMap {
  late final Function(int) _voterFunction;
  late final Function(String) _factoryFunction;

  ExceptionMap({
    required Function(int) voterFunction,
    required Function(String) factoryFunction,
  }) {
    _voterFunction = voterFunction;
    _factoryFunction = factoryFunction;
  }

  get voterFunction => _voterFunction;
  get factoryFunction => _factoryFunction;
}
