import SwiftUI

@main
struct Progress_BatteryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // This can be replaced with your settings view if needed.
        }
    }
}
