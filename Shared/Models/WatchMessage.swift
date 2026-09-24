import Foundation

/// Payloads exchanged over WatchConnectivity between the iPhone and the watch.
enum WatchMessage: Codable, Sendable {
    /// iPhone → watch: latest computed metrics.
    case snapshot(MetricSnapshot)
    /// iPhone → watch: an action to suggest to the user.
    case recommendation(RecoveryAction)
    /// Watch → iPhone: user feedback on a recommendation.
    case feedback(action: RecoveryAction, feedback: ActionFeedback, date: Date)
    /// Watch → iPhone: self-reported stress label used for calibration.
    case selfReport(stressed: Bool, date: Date)
}
