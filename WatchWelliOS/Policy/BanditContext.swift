import Foundation

/// Context (state) fed to the bandit (README §4.1).
struct BanditContext: Sendable {
    var stressIndex: Double          // 0–100
    var sleepScore: Double           // 0–100
    var hourOfDay: Int               // 0–23
    var weekday: Int                 // 1–7
    var recentActivity: Double       // 0...1, normalized recent step/energy level

    static let featureCount = 7

    /// Feature vector with a bias term and cyclical time encoding.
    var features: [Double] {
        let hourAngle = 2 * Double.pi * Double(hourOfDay) / 24
        let isWeekend = (weekday == 1 || weekday == 7) ? 1.0 : 0.0
        return [1, stressIndex / 100, sleepScore / 100, sin(hourAngle), cos(hourAngle), isWeekend, recentActivity]
    }
}
