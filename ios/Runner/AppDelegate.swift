import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Keeps the app's data out of iCloud backups: the folders Flutter names
    // are marked "excluded from backup", contents included.
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BackupExclusion") else { return }
    let channel = FlutterMethodChannel(name: "shopping_list/storage", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup", let paths = call.arguments as? [String] else {
        result(FlutterMethodNotImplemented)
        return
      }
      for path in paths {
        var url = URL(fileURLWithPath: path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? url.setResourceValues(values)
      }
      result(nil)
    }
  }
}
