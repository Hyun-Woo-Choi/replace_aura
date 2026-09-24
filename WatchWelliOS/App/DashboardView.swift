import SwiftUI

/// v0.1 raw data dashboard.
struct DashboardView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    LabeledContent("Stress index", value: format(model.snapshot?.stressIndex))
                    LabeledContent("Sleep score", value: format(model.snapshot?.sleepScore))
                }
                if !model.isAuthorized {
                    Section {
                        Text("Health access has not been granted yet.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("WatchWell")
            .refreshable { await model.refresh() }
        }
    }

    private func format(_ value: Double?) -> String {
        value.map { String(Int($0.rounded())) } ?? "—"
    }
}
