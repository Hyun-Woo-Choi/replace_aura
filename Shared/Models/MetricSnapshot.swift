import Foundation

/// How much the app trusts a score, based on how much baseline data exists.
enum ScoreConfidence: String, Codable, Sendable {
    case low      // cold start: baseline still being built
    case normal
}

/// A computed stress or sleep score at a point in time. Values are 0–100.
struct MetricSnapshot: Codable, Sendable, Equatable {
    var date: Date
    var stressIndex: Double?
    var sleepScore: Double?
    var confidence: ScoreConfidence
}
