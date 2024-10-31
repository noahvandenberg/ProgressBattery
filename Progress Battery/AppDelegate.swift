import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the status bar controller
        statusBarController = StatusBarController()
    }
}
