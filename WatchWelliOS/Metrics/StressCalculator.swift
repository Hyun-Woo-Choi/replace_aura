import Foundation

/// Rule-based stress index (README §3.1). Weights are calibrated later (Phase 2).
struct StressCalculator {
    struct Weights: Codable, Sendable {
        var hrv = 1.0
        var restingHeartRate = 0.7
        var respiratoryRate = 0.3
    }

    struct Baselines: Sendable {
        var hrv: Baseline
        var restingHeartRate: Baseline
        var respiratoryRate: Baseline?
    }

    var weights = Weights()

    /// Returns a 0–100 stress index. Lower HRV and higher RHR / respiratory rate raise stress.
    func stressIndex(hrv: Double, restingHeartRate: Double, respiratoryRate: Double?,
                     baselines: Baselines) -> Double {
        var raw = -weights.hrv * baselines.hrv.zScore(hrv)
            + weights.restingHeartRate * baselines.restingHeartRate.zScore(restingHeartRate)
        if let respiratoryRate, let respBaseline = baselines.respiratoryRate {
            raw += weights.respiratoryRate * respBaseline.zScore(respiratoryRate)
        }
        return 100 * sigmoid(raw)
    }

    /// Whether a sample falls inside (or right after) a workout and must be excluded.
    static func isExcluded(_ date: Date, workouts: [DateInterval]) -> Bool {
        workouts.contains { interval in
            date >= interval.start && date <= interval.end.addingTimeInterval(AppConstants.postWorkoutExclusion)
        }
    }

    private func sigmoid(_ x: Double) -> Double { 1 / (1 + exp(-x)) }
}
