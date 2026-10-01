import Flutter
import UIKit
import GoogleMaps
import UserNotifications
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase must be configured before the plugin registrant so firebase_core
    // and firebase_messaging see an initialised default app. Idempotent with the
    // Dart-side Firebase.initializeApp(); configuring natively is what lets the
    // APNs token resolve reliably on cold start.
    FirebaseApp.configure()

    // Maps API key is injected via Info.plist (`GMSApiKey`), which resolves
    // `$(MAPS_API_KEY)` from `ios/Flutter/Secrets.xcconfig` (gitignored).
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !key.isEmpty {
      GMSServices.provideAPIKey(key)
    } else {
      NSLog("⚠️ slfdrive: GMSApiKey missing — see ios/Flutter/Secrets.xcconfig.example")
    }

    // FlutterAppDelegate already conforms to UNUserNotificationCenterDelegate and
    // forwards to plugins, so this is what routes foreground presentation and tap
    // callbacks to flutter_local_notifications / firebase_messaging. Under the
    // UIScene lifecycle plugins register later (didInitializeImplicitFlutterEngine),
    // but Apple requires the delegate to be assigned before launch completes or
    // the response for a cold-start notification tap is dropped.
    UNUserNotificationCenter.current().delegate = self

    // Ask APNs for a device token eagerly, before Dart requests notification
    // permission. This is the counterpart to the getAPNSToken() retry loop in
    // PushMessagingService: without it, FirebaseMessaging.getToken() on a first
    // cold start is a race that frequently returns nil.
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle: the engine is created by the storyboard's
  // FlutterViewController when the scene connects, after didFinishLaunching, so
  // plugin registration has to happen here rather than against the app delegate.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Re-assert after the registrant so it wins over anything a plugin installed.
    UNUserNotificationCenter.current().delegate = self
  }

  // Firebase's method swizzling (left enabled — see FirebaseAppDelegateProxyEnabled
  // in Info.plist) already forwards this, but assigning apnsToken explicitly costs
  // nothing and eliminates the "APNS token has not been set yet" class of failures.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("⚠️ slfdrive: APNs registration failed — \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
