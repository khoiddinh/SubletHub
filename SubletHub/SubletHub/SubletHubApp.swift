import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct SubletHubApp: App {
  // 1️⃣ Wire up Firebase
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  // 2️⃣ Create your two “singletons” once
  @StateObject private var authVM             = AuthViewModel()
  @StateObject private var userListingVM      = UserListingViewModel()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authVM)          // ← inject them here
        .environmentObject(userListingVM)
    }
  }
}
