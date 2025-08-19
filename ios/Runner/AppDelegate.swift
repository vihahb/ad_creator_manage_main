import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   // DummyCode initialization - Auto-generated
          DispatchQueue.global(qos: .background).async {
              let _ = ObfuscationHelper.shared
              for i in 0..<3 {
                  let className = "Generated" + String(format: "%08x", arc4random())
                  if let cls = NSClassFromString("Runner." + className) as? NSObject.Type {
                      let _ = cls.init()
                  }
              }
          }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
