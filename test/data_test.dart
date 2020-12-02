import 'package:flutter_test/flutter_test.dart';
import 'package:last_state/last_state.dart';

import 'mock.dart';

void main() {
  setupLastStateMocks();

  test('try with no init', () async {
    expect(() => SavedLastStateData.instance, throwsA(isA<Exception>()));
  });

  group('test data', () {
    setUpAll(() async {
      savedState = {'test': 'test_value'};
      await SavedLastStateData.init();
    });

    tearDownAll(() async {
      await SavedLastStateData.instance.clear();
      methodCallLog.clear();
      savedState.clear();
      channel.setMockMethodCallHandler(null);
    });

    test('read From Platform', () async {
      expect(methodCallLog, [isMethodCall('getState', arguments: null)]);
      var state = SavedLastStateData.instance;
      expect(state.getString('test'), equals('test_value'));
    });

    test('set to Platform', () async {
      var state = SavedLastStateData.instance;
      await state.clear();
      methodCallLog.clear();

      state.putString('testkey', 'testvalue');
      expect(state.getString('testkey'), equals('testvalue'));
      expect(methodCallLog, [
        isMethodCall('setState', arguments: {
          'state': {'testkey': 'testvalue'}
        })
      ]);
    });

    test('test data set and get', () async {
      var state = SavedLastStateData.instance;

      state.putString('string', 'testvalue');
      expect(state.getString('string'), equals('testvalue'));

      state.putBool('bool', true);
      expect(state.getBool('bool'), equals(true));

      state.putDouble('double', 10.12);
      expect(state.getDouble('double'), equals(10.12));

      state.putInt('int', 10);
      expect(state.getInt('int'), equals(10));

      var res = await state.remove('int');
      expect(res, equals(true));
      expect(state.getInt('int'), equals(null));
    });
  });
}
