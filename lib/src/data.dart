import 'package:flutter/material.dart';
import 'package:last_state/src/platform.dart';

import 'navigation.dart';

class SavedLastStateData {
  Map<String, dynamic> _data = {};
  static const String _lastRouteKey = 'LastStateRouteKey';
  static SavedLastStateData _instance;
  LastStateNavigationObserver _navigationObserver;
  bool _isRestored = false;
  bool _isFirstLoad = true;
  bool clearDataOnChangeRoute = true;

  String get lastRoute => _data[_lastRouteKey];

  bool get isRestored => _isRestored;

  LastStateNavigationObserver get navigationObserver => _navigationObserver;

  static Future<SavedLastStateData> init() async {
    if (_instance == null) {
      _instance = SavedLastStateData();
      _instance._data = await _load() ?? {};
      if (_instance._data.isNotEmpty) _instance._isRestored = true;
      _instance._navigationObserver = LastStateNavigationObserver(_instance);
    }

    return _instance;
  }

  static SavedLastStateData get instance {
    _checkInit();
    return _instance;
  }

  static void _checkInit() {
    if (_instance == null) {
      throw Exception('''\n
  LastState not initialized.
  Call await LastState.init() before any other LastState call.
          
  main() async {
    await LastState.init();
    runApp(MyApp());
  }
      ''');
    }
  }

  Future<void> setLastRoute(Route<dynamic> lastRoute) async {
    if (lastRoute?.settings == null) return;
    //if is it first load no need to do nothing
    //I added this test for two reason:
    //1- clear old state or page data and keep only last data
    //2- prevent clearing the loaded data for the first time when restoring state
    //(push the old route)
    if (!_isRestored || !_isFirstLoad) {
      // clean previous route data
      if (clearDataOnChangeRoute) _data.clear();
      //save new route
      _data[_lastRouteKey] = lastRoute?.settings?.name;
      _write();
    } else {
      _isFirstLoad = false;
    }
  }

  dynamic _getValue(String key) {
    return _data["$key"];
  }

  Future<void> _putValue(String key, dynamic value) {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
    return _write();
  }

  String getString(String key) {
    return _getValue(key) as String;
  }

  Future<void> putString(String key, String value) async {
    return _putValue(key, value);
  }

  int getInt(String key) {
    return _getValue(key) as int;
  }

  Future<void> putInt(String key, int value) async {
    return _putValue(key, value);
  }

  double getDouble(String key) {
    return _getValue(key) as double;
  }

  Future<void> putDouble(String key, double value) async {
    return _putValue(key, value);
  }

  bool getBool(String key) {
    return (_getValue(key) as bool);
  }

  Future<void> putBool(String key, bool value) async {
    return _putValue(key, value);
  }

  /// Remove the value with the specified [key]
  /// Returns true if the value was removed, false otherwise
  Future<bool> remove(String key) async {
    if (_getValue(key) != null) {
      await _putValue(key, null);
      return true;
    } else {
      return false;
    }
  }

  /// Clear all data. [SavedLastStateData]s can be nested when created using [child]. Calling [clear] on
  /// any parent, will clear all children data.
  Future<void> clear() {
    _data.clear();
    return _write();
  }

  Future<void> _write() async {
    return FlutterNativeState.set(_data);
  }

  static Future<Map<String, dynamic>> _load() async {
    return FlutterNativeState.get();
  }
}
