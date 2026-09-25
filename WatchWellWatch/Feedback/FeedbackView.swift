import SwiftUI

/// 👍/👎 on a recommended action; part of the bandit reward.
struct FeedbackView: View {
    let action: RecoveryAction
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text(action.title).font(.headline)
            Text("Did this help?").font(.footnote)
            HStack {
                Button("👍") { send(.thumbsUp) }
                Button("👎") { send(.thumbsDown) }
            }
        }
    }

    private func send(_ feedback: ActionFeedback) {
        ConnectivityManager.shared.send(.feedback(action: action, feedback: feedback, date: .now))
        dismiss()
    }
}
