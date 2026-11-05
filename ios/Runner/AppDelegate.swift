import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let incomingFiles = IncomingFiles()

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

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "IncomingFiles") {
      incomingFiles.attach(to: registrar)
    }
  }
}

/// Hands Flutter the content of a file opened with the app ("Open in", Files,
/// Mail): the one that launched the app through `take`, the following ones
/// through `received`. Same channel as Android's MainActivity. Other URLs
/// (`shopping-list://` links) are left to Flutter.
class IncomingFiles: NSObject, FlutterSceneLifeCycleDelegate {
  private var channel: FlutterMethodChannel?
  private var pending: String?
  /// Whether Dart listens yet; until then a file waits in [pending].
  private var listening = false

  func attach(to registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "shopping_list/incoming", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "take" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self?.pending)
      self?.pending = nil
      self?.listening = true
    }
    self.channel = channel
    registrar.addSceneDelegate(self)
  }

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    guard let content = read(connectionOptions?.urlContexts ?? []) else { return false }
    pending = content
    return true
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let content = read(URLContexts) else { return false }
    if listening {
      channel?.invokeMethod("received", arguments: content)
    } else {
      pending = content
    }
    return true
  }

  /// The text of the first file among [contexts]; `nil` when none is a file.
  private func read(_ contexts: Set<UIOpenURLContext>) -> String? {
    guard let url = contexts.map(\.url).first(where: \.isFileURL) else { return nil }
    let scoped = url.startAccessingSecurityScopedResource()
    defer {
      if scoped { url.stopAccessingSecurityScopedResource() }
      // iOS copies the file into the app's Inbox: it is no longer needed.
      if url.path.contains("/Inbox/") { try? FileManager.default.removeItem(at: url) }
    }
    return try? String(contentsOf: url, encoding: .utf8)
  }
}
