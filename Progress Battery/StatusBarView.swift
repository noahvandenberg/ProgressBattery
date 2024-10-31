import SwiftUI

struct StatusBarView: View {
    @State private var progress: Double = 0.0
    @State private var daysLeft: Int = 0
    @State private var totalDays: Int = 0

    var body: some View {
        ProgressView(value: progress)
            .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
            .frame(width: 120)
            .onAppear {
                updateProgress()
                scheduleDailyUpdate()
            }
            .help("\(daysLeft) days left in the month")
    }

    func updateProgress() {
        let calendar = Calendar.current
        let date = Date()

        guard
            let range = calendar.range(of: .day, in: .month, for: date),
            let currentDay = calendar.dateComponents([.day], from: date).day
        else {
            return
        }

        totalDays = range.count
        daysLeft = totalDays - currentDay
        progress = Double(currentDay) / Double(totalDays)
    }

    func scheduleDailyUpdate() {
        // Calculate the time interval until the next day
        let calendar = Calendar.current
        let now = Date()

        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            return
        }

        let midnight = calendar.startOfDay(for: tomorrow)
        let timeInterval = midnight.timeIntervalSince(now)

        // Schedule the update
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            self.updateProgress()
            self.scheduleDailyUpdate()
        }
    }
}
