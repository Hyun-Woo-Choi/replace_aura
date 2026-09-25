import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var connectivity: ConnectivityManager
    @State private var snapshot: MetricSnapshot?
    @State private var recommendation: RecoveryAction?

    var body: some View {
        NavigationStack {
            List {
                ScoreRow(title: "Stress", value: snapshot?.stressIndex)
                ScoreRow(title: "Sleep", value: snapshot?.sleepScore)
                if snapshot?.confidence == .low {
                    Text("Building your baseline…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if let recommendation {
                    NavigationLink("Try: \(recommendation.title)") {
                        FeedbackView(action: recommendation)
                    }
                }
                NavigationLink("How do you feel?") {
                    SelfReportView()
                }
            }
            .navigationTitle("WatchWell")
        }
        .onReceive(connectivity.$lastMessage) { message in
            switch message {
            case .snapshot(let value): snapshot = value
            case .recommendation(let action): recommendation = action
            default: break
            }
        }
    }
}

private struct ScoreRow: View {
    let title: String
    let value: Double?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value.map { String(Int($0.rounded())) } ?? "—")
                .font(.title3.monospacedDigit())
        }
    }
}
