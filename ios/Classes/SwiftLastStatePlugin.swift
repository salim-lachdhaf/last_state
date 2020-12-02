import Flutter
import UIKit

public class SwiftLastStatePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "last_state", binaryMessenger: registrar.messenger())
    let instance = SwiftLastStatePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if (call.method == "getState") {
          result(StateStorage.instance.get())
      } else if (call.method == "setState") {
          guard let argsDict = call.arguments as? [String: Any] else {
              result(nil)
              return
          }
          let state = argsDict["state"];
          StateStorage.instance.update(state: state as! [String : Any])
          result(StateStorage.instance.get())
      } else {
          result(nil)
      }
   }
}
