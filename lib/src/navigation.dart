import 'package:flutter/widgets.dart';
import 'package:last_state/last_state.dart';

class LastStateNavigationObserver extends RouteObserver<PageRoute<dynamic>> {
  final SavedLastStateData lastState;

  LastStateNavigationObserver(this.lastState);

  @override
  Future<void> didPop(Route<dynamic> route, Route<dynamic> previousRoute) async {
    await lastState.setLastRoute(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  Future<void> didPush(Route<dynamic> route, Route<dynamic> previousRoute) async{
    await lastState.setLastRoute(route);
    super.didPush(route, previousRoute);
  }

  @override
  Future<void> didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) async {
    await lastState.setLastRoute(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  Future<void> didRemove(Route<dynamic> route, Route<dynamic> previousRoute) async {
    await lastState.setLastRoute(previousRoute);
    super.didRemove(route, previousRoute);
  }
}
