import Foundation

/// Personal baseline for a single signal: rolling median and standard deviation.
struct Baseline: Codable, Sendable, Equatable {
    var median: Double
    var std: Double
    var sampleDays: Int

    /// Builds a baseline from values collected over the rolling window.
    init?(values: [Double], sampleDays: Int) {
        guard values.count >= 2 else { return nil }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        median = sorted.count.isMultiple(of: 2) ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid]
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(values.count - 1)
        std = variance.squareRoot()
        self.sampleDays = sampleDays
    }

    /// z-score of `value` relative to this baseline.
    func zScore(_ value: Double) -> Double {
        guard std > 0 else { return 0 }
        return (value - median) / std
    }

    var confidence: ScoreConfidence {
        sampleDays >= AppConstants.coldStartDays ? .normal : .low
    }
}
