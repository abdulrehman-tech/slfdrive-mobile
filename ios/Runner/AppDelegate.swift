import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Maps API key is injected via Info.plist (`GMSApiKey`), which resolves
    // `$(MAPS_API_KEY)` from `ios/Flutter/Secrets.xcconfig` (gitignored).
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !key.isEmpty {
      GMSServices.provideAPIKey(key)
    } else {
      NSLog("⚠️ slfdrive: GMSApiKey missing — see ios/Flutter/Secrets.xcconfig.example")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
