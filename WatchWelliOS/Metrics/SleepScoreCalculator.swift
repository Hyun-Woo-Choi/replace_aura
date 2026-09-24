import Foundation

/// Sleep score (README §3.2). Each component is normalized to 0...1 before weighting.
struct SleepScoreCalculator {
    struct Night: Sendable {
        var timeInBed: TimeInterval
        var timeAsleep: TimeInterval
        var deep: TimeInterval
        var rem: TimeInterval
        /// 0...1, how close bedtime/wake time are to the user's usual schedule.
        var consistency: Double
        /// 0...1, 1 = sleeping HR and wrist temperature are at baseline.
        var physiologyNormality: Double
    }

    var sleepGoal: TimeInterval = 8 * 3600

    func score(for night: Night) -> Double {
        guard night.timeInBed > 0, night.timeAsleep > 0 else { return 0 }
        let duration = min(night.timeAsleep / sleepGoal, 1)
        let efficiency = min(night.timeAsleep / night.timeInBed, 1)
        // ~45% deep + REM is treated as full marks.
        let stages = min((night.deep + night.rem) / night.timeAsleep / 0.45, 1)

        let total = 0.35 * duration
            + 0.20 * efficiency
            + 0.20 * stages
            + 0.15 * clamp(night.consistency)
            + 0.10 * clamp(night.physiologyNormality)
        return 100 * total
    }

    private func clamp(_ x: Double) -> Double { min(max(x, 0), 1) }
}
