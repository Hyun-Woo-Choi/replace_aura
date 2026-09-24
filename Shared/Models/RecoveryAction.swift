import Foundation

/// The action set of the contextual bandit (README §4.1).
enum RecoveryAction: String, CaseIterable, Codable, Sendable, Identifiable {
    case breathing1Min
    case breathing3Min
    case shortWalk
    case drinkWater
    case noNotification

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breathing1Min: "1-min breathing"
        case .breathing3Min: "3-min breathing"
        case .shortWalk: "Short walk"
        case .drinkWater: "Drink water"
        case .noNotification: "No notification"
        }
    }
}

/// User feedback on a recommendation, used as part of the reward.
enum ActionFeedback: String, Codable, Sendable {
    case thumbsUp
    case thumbsDown
}
