import SwiftUI

/// "Are you feeling stressed right now?" — labels for supervised calibration (Phase 2).
struct SelfReportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("Are you feeling stressed right now?")
                .multilineTextAlignment(.center)
            HStack {
                Button("Yes") { send(true) }
                Button("No") { send(false) }
            }
        }
    }

    private func send(_ stressed: Bool) {
        ConnectivityManager.shared.send(.selfReport(stressed: stressed, date: .now))
        dismiss()
    }
}
