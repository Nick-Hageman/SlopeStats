import UIKit
import WatchConnectivity

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var wcSessionDelegate: WCSessionDelegateImpl?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set up WCSession if supported
        if WCSession.isSupported() {
            wcSessionDelegate = WCSessionDelegateImpl()  // Create the delegate instance
            WCSession.default.delegate = wcSessionDelegate  // Set it as the global WCSession delegate
            WCSession.default.activate()  // Activate the session
        }
        return true
    }
}
