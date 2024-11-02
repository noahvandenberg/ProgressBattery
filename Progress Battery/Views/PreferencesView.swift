import SwiftUI

struct PreferencesView: View {
    @AppStorage("birthYear") private var birthYear: Int = 1998
    @AppStorage("lifeExpectancy") private var lifeExpectancy: Double = 80.0
    @AppStorage("updateInterval") private var updateInterval: Double = 60.0
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                birthYear: $birthYear,
                lifeExpectancy: $lifeExpectancy,
                updateInterval: $updateInterval,
                launchAtLogin: $launchAtLogin
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 375, height: 250)
        .padding()
    }
}

struct GeneralSettingsView: View {
    @Binding var birthYear: Int
    @Binding var lifeExpectancy: Double
    @Binding var updateInterval: Double
    @Binding var launchAtLogin: Bool
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Birth Year:")
                    Picker("Birth Year", selection: $birthYear) {
                        ForEach((1900...Calendar.current.component(.year, from: Date())), id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                }
                
                HStack {
                    Text("Life Expectancy:")
                    Slider(value: $lifeExpectancy, in: 60...120, step: 1) {
                        Text("Life Expectancy")
                    }
                    Text("\(Int(lifeExpectancy)) years")
                        .monospacedDigit()
                }
                
                HStack {
                    Text("Update Interval:")
                    Picker("Update Interval", selection: $updateInterval) {
                        Text("30 seconds").tag(30.0)
                        Text("1 minute").tag(60.0)
                        Text("5 minutes").tag(300.0)
                    }
                }
                
                Toggle("Launch at Login", isOn: $launchAtLogin)
            }
        }
        .padding()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
            
            Text("Progress Battery")
                .font(.title2)
                .bold()
            
            Text("Version 1.0.0")
                .font(.caption)
            
            Text("A simple menu bar app to track the progress of various time metrics.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Link("GitHub Repository", destination: URL(string: "https://github.com/yourusername/progress-battery")!)
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    PreferencesView()
} 