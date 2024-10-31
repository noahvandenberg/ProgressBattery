import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private var selectedMetric: String = "Hour" // Track the selected metric (Hour, Day, Month, Year, Life)
    private var timer: Timer?

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

        // Set up a timer to update the icon every minute
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(refreshStatusBarIcon), userInfo: nil, repeats: true)
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
        guard let range = calendar.range(of: .day, in: .month, for: now),
              let currentDay = calendar.dateComponents([.day], from: now).day else { return 0.0 }

        let totalDays = Double(range.count)
        return Double(currentDay - 1) / totalDays
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
        let averageLifeSpan: Double = 80
        let birthYear = 1998 // Replace with actual birth year
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        let age = Double(currentYear - birthYear)
        return age / averageLifeSpan
    }

    // Draw the custom icon based on the progress
    private func updateStatusBarIcon(withProgress progress: Double, percentage: Int) {
        let iconSize = NSSize(width: 24, height: 11)  // Adjusted height to 11 and width to 24
        let image = NSImage(size: iconSize)
        image.lockFocus()

        // Draw the outline rectangle with slightly rounded corners
        let outlineRect = NSRect(x: 0, y: 0, width: iconSize.width, height: iconSize.height)
        let outlinePath = NSBezierPath(roundedRect: outlineRect, xRadius: 3, yRadius: 3)  // Slightly rounded corners
        NSColor.white.withAlphaComponent(0.5).setStroke()  // White outline with 50% opacity
        outlinePath.lineWidth = 1.5  // Slightly bolder outline for better visibility
        outlinePath.stroke()

        // Draw the filled progress bar
        let fillWidth = outlineRect.width * CGFloat(progress)
        let fillRect = NSRect(x: 2, y: 2, width: fillWidth - 4, height: outlineRect.height - 4)
        let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: 2, yRadius: 2)  // Rounded corners for fill as well
        NSColor.white.setFill()  // White fill color
        fillPath.fill()

        image.unlockFocus()

        // Set the image and title for the status bar button
        if let button = statusItem.button {
            button.image = image
            button.imagePosition = .imageTrailing
            button.attributedTitle = NSAttributedString(
                string: "\(percentage)% ",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 11),  // Font size set to 11 for a subtle appearance
                    .foregroundColor: NSColor.white        // White font color
                ]
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
        // Handle preferences opening here
        print("Preferences clicked")
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
