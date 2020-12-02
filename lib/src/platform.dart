import 'package:flutter/services.dart';

class FlutterNativeState {
  static const MethodChannel _channel =
      const MethodChannel('last_state');

  static Future<Map<String, dynamic>> get() async {
    return (await _channel.invokeMapMethod('getState')) ?? {};
  }

  static Future<Map<dynamic, dynamic>> set(Map<dynamic, dynamic> state) async {
    return await _channel.invokeMethod('setState', {"state": state});
  }
}
