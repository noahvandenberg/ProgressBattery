import AppKit
import SwiftUI

class StatusBarController {
    private var statusItem: NSStatusItem
    private var selectedMetric: String = "Hour" // Track the selected metric (Hour, Day, Month, Year, Life)
    private var timer: Timer?
    private var preferencesWindow: NSWindow?

    init() {
        // Create the status bar item with a variable length to adjust to content
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Initial update for the selected metric progress
        refreshStatusBarIcon()

        // Set up the menu
        let menu = NSMenu()

        // Add menu items for different progress types
        menu.addItem(createMenuItem(title: "Hour", isChecked: true))
        menu.addItem(createMenuItem(title: "Day"))
        menu.addItem(createMenuItem(title: "Month"))
        menu.addItem(createMenuItem(title: "Year"))
        menu.addItem(createMenuItem(title: "Life"))

        // Add a separator
        menu.addItem(NSMenuItem.separator())

        // Add Preferences and Quit menu items
        let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: "")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        // Assign the menu to the status item
        statusItem.menu = menu

        // Update timer interval based on user preferences
        let updateInterval = UserDefaults.standard.double(forKey: "updateInterval")
        timer = Timer.scheduledTimer(
            timeInterval: updateInterval,
            target: self,
            selector: #selector(refreshStatusBarIcon),
            userInfo: nil,
            repeats: true
        )
    }

    // Helper function to create a menu item with clickable action
    private func createMenuItem(title: String, isChecked: Bool = false) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: #selector(selectProgressItem(_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.state = isChecked ? .on : .off
        menuItem.representedObject = title

        return menuItem
    }

    // Update the status bar icon and title based on the selected metric progress
    @objc private func refreshStatusBarIcon() {
        var progress: Double = 0.0

        switch selectedMetric {
        case "Hour":
            progress = getHourProgress()
        case "Day":
            progress = getDayProgress()
        case "Month":
            progress = getMonthProgress()
        case "Year":
            progress = getYearProgress()
        case "Life":
            progress = getLifeProgress()
        default:
            progress = getHourProgress()
        }

        let progressPercentage = Int(progress * 100)
        updateStatusBarIcon(withProgress: progress, percentage: progressPercentage)
    }

    // Calculate the progress within the current hour
    private func getHourProgress() -> Double {
        let calendar = Calendar.current
        let now = Date()

        let startOfHour = calendar.dateInterval(of: .hour, for: now)?.start ?? Date()
        let endOfHour = calendar.date(byAdding: .hour, value: 1, to: startOfHour) ?? Date()

        let totalSecondsInHour = endOfHour.timeIntervalSince(startOfHour)
        let elapsedSeconds = now.timeIntervalSince(startOfHour)

        return elapsedSeconds / totalSecondsInHour
    }

    // Calculate the progress within the current day
    private func getDayProgress() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0.0 }

        let totalSecondsInDay = endOfDay.timeIntervalSince(startOfDay)
        let elapsedSeconds = now.timeIntervalSince(startOfDay)

        return elapsedSeconds / totalSecondsInDay
    }

    // Calculate the progress within the current month
    private func getMonthProgress() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of the current month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              // Get start of next month
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return 0.0
        }
        
        // Calculate total seconds in the month and elapsed seconds
        let totalSecondsInMonth = startOfNextMonth.timeIntervalSince(startOfMonth)
        let elapsedSeconds = now.timeIntervalSince(startOfMonth)
        
        return elapsedSeconds / totalSecondsInMonth
    }

    // Calculate the progress within the current year
    private func getYearProgress() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)

        let startOfYear = calendar.date(from: DateComponents(year: year)) ?? Date()
        guard let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) else { return 0.0 }

        let totalSecondsInYear = endOfYear.timeIntervalSince(startOfYear)
        let elapsedSeconds = now.timeIntervalSince(startOfYear)

        return elapsedSeconds / totalSecondsInYear
    }

    // Calculate the progress in a typical human lifespan (assuming average lifespan of 80 years)
    private func getLifeProgress() -> Double {
        let defaults = UserDefaults.standard
        let birthYear = defaults.integer(forKey: "birthYear")
        let lifeExpectancy = defaults.double(forKey: "lifeExpectancy")
        
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        let age = Double(currentYear - birthYear)
        return age / lifeExpectancy
    }

    // Draw the custom icon based on the progress
    private func updateStatusBarIcon(withProgress progress: Double, percentage: Int) {
        // Use standard system metrics for touch targets (though this is menu bar)
        let iconSize = NSSize(width: 28, height: 16)  // Slightly larger for better visibility
        let image = NSImage(size: iconSize)
        image.lockFocus()

        // Create a clean background with proper padding
        let outlineRect = NSRect(x: 1, y: 3, width: iconSize.width - 2, height: iconSize.height - 6)
        let outlinePath = NSBezierPath(roundedRect: outlineRect, xRadius: 4, yRadius: 4)  // More rounded corners
        
        // Use system colors for better integration
        NSColor.white.withAlphaComponent(0.3).setStroke()  // Subtle outline
        outlinePath.lineWidth = 1.0  // Thinner line for elegance
        outlinePath.stroke()

        // Draw the progress bar with proper padding and rounded edges
        if progress > 0.0 {
            let progressPadding: CGFloat = 2.0
            let fillWidth = max(2.0, (outlineRect.width - (progressPadding * 2)) * CGFloat(progress))
            let fillRect = NSRect(
                x: outlineRect.minX + progressPadding,
                y: outlineRect.minY + progressPadding,
                width: fillWidth,  // Fixed: width parameter order
                height: outlineRect.height - (progressPadding * 2)
            )
            
            let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: 3, yRadius: 3)
            
            // Use a gradient fill for more depth
            let gradient = NSGradient(
                starting: NSColor.white.withAlphaComponent(0.95),
                ending: NSColor.white.withAlphaComponent(0.85)
            )
            gradient?.draw(in: fillPath, angle: 90)
        }

        image.unlockFocus()

        // Update the status item with improved typography
        if let button = statusItem.button {
            button.image = image
            button.imagePosition = .imageTrailing
            
            // Create attributed string with improved typography
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium),
                .foregroundColor: NSColor.white.withAlphaComponent(0.85),
                .paragraphStyle: paragraphStyle,
                .kern: 0.5  // Add slight kerning for better readability
            ]
            
            button.attributedTitle = NSAttributedString(
                string: String(format: "%d%% ", percentage),
                attributes: attributes
            )
        }
    }

    // Handle selection of a menu item
    @objc func selectProgressItem(_ sender: NSMenuItem) {
        // Deselect all other items
        if let menu = sender.menu {
            for item in menu.items where item.action == #selector(selectProgressItem(_:)) {
                item.state = .off
            }
        }

        // Mark the selected item as checked
        sender.state = .on

        // Update the selected metric
        if let metric = sender.representedObject as? String {
            selectedMetric = metric
        }

        // Update the status bar icon and title based on the new selection
        refreshStatusBarIcon()
    }

    @objc func openPreferences() {
        if preferencesWindow == nil {
            let preferencesView = PreferencesView()
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 375, height: 250),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            preferencesWindow?.center()
            preferencesWindow?.setFrameAutosaveName("Preferences")
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.contentView = NSHostingView(rootView: preferencesView)
            preferencesWindow?.title = "Preferences"
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
