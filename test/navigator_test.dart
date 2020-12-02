import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:last_state/last_state.dart';

import 'mock.dart';

void main() {
  setupLastStateMocks();

  tearDownAll(() {
    savedState.clear();
    methodCallLog.clear();
    channel.setMockMethodCallHandler(null);
  });

  group('LastStateRouteObserver saves current route [WITH old saved Routes]',
      () {
    setUp(() async {
      savedState = {'LastStateRouteKey': 'old'};
      await SavedLastStateData.init();
      SavedLastStateData.instance.clearDataOnChangeRoute = true;
    });

    tearDown(() async {
      await SavedLastStateData.instance.clear();
    });

    test('didPush saves route correctly', () async {
      var state = SavedLastStateData.instance;
      var observer = LastStateNavigationObserver(state);

      //check that first action (push,pop,remove,...) is not loaded because it's
      //related to state restore in [SavedLastStateData.init()]
      //because it's already saved
      await observer.didPush(
        _MockRoute("newRoute"),
        _MockRoute("oldRoute"),
      );
      expect(state.lastRoute, "old");

      //after restoring last state new state should be captured
      await observer.didPop(_MockRoute("old"), _MockRoute("new"));
      expect(state.lastRoute, "new");
    });
  });

  group('LastStateRouteObserver saves current route [NO old saved Routes]', () {
    setUp(() async {
      await SavedLastStateData.init();
      await SavedLastStateData.instance.clear();
    });

    tearDown(() async {
      await SavedLastStateData.instance.clear();
    });

    test('didPop saves route correctly', () async {
      var state = SavedLastStateData.instance;
      var observer = LastStateNavigationObserver(state);

      await observer.didPop(_MockRoute("old"), null);
      expect(state.lastRoute, null);

      await observer.didPop(_MockRoute("old"), _MockRoute("new"));
      expect(state.lastRoute, "new");
    });

    test('didPush saves route correctly', () async {
      var state = SavedLastStateData.instance;
      var observer = LastStateNavigationObserver(state);

      await observer.didPush(null, _MockRoute("old"));
      expect(state.lastRoute, null);

      await observer.didPush(
        _MockRoute("new"),
        _MockRoute("old"),
      );
      expect(state.lastRoute, "new");
    });

    test('didRemove saves route correctly', () async {
      var state = SavedLastStateData.instance;
      var observer = LastStateNavigationObserver(state);

      await observer.didRemove(_MockRoute("old"), null);
      expect(state.lastRoute, null);

      await observer.didRemove(_MockRoute("old"), _MockRoute("new"));
      expect(state.lastRoute, "new");
    });

    test('didReplace saves route correctly', () async {
      var state = SavedLastStateData.instance;
      var observer = state.navigationObserver;

      await observer.didReplace(oldRoute: _MockRoute("old"), newRoute: null);
      expect(state.lastRoute, null);

      await observer.didReplace(
          oldRoute: _MockRoute("old"), newRoute: _MockRoute("new"));
      expect(state.lastRoute, "new");
    });
  });
}

class _MockRoute extends PageRoute {
  _MockRoute(String name) : super(settings: RouteSettings(name: name));

  @override
  Color get barrierColor => throw UnimplementedError();

  @override
  String get barrierLabel => throw UnimplementedError();

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return null;
  }

  @override
  bool get maintainState => throw UnimplementedError();

  @override
  Duration get transitionDuration => throw UnimplementedError();
}
