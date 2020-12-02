import 'package:flutter/material.dart';
import 'package:last_state/last_state.dart';

/// Mixin that supplies [SavedLastStateData] to a [StatefulWidget]s [State] class.
/// The widget tree must contain a [SavedState] widget that is a parent of the [StatefulWidget]
/// to locate the [SavedLastStateData].
mixin LastStateRestoration<T extends StatefulWidget> on State<T> {
  bool _didRestoreState = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var state = SavedLastStateData.instance;

    if (state.isRestored && !_didRestoreState) {
      lastStateRestored();
      _didRestoreState = true;
    }
  }

  /// Will be called once to restore the state. This method will always be
  /// called after the state restoration has completed, even if there's no
  /// previously saved state.
  void lastStateRestored();
}
