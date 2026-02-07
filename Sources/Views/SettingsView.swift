import SwiftUI

struct SettingsView: View {
    @Bindable var state: AppState

    var body: some View {
        Form {
            Section("Scan Path") {
                TextField("Path", text: $state.config.scanPath)
                    .font(.system(.body, design: .monospaced))
            }

            Section("GitHub") {
                TextField("Owner", text: $state.config.githubOwner)
            }

            Section("Thresholds") {
                Stepper("Active: \(state.config.activeDays) days", value: $state.config.activeDays, in: 1...365)
                Stepper("Stale: \(state.config.staleDays) days", value: $state.config.staleDays, in: 1...365)
                Stepper("Refresh: \(state.config.refreshIntervalMinutes) min", value: $state.config.refreshIntervalMinutes, in: 1...60)
            }

            Section {
                Button("Save") {
                    state.config.save()
                    state.startPolling()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .formStyle(.grouped)
        .frame(width: 300)
        .padding()
    }
}
