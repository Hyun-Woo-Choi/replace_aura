import Foundation

/// App-wide constants shared by the iOS and watchOS targets.
enum AppConstants {
    /// Rolling window used to compute the personal baseline.
    static let baselineWindowDays = 28
    /// Minimum days of data before scores are shown with full confidence.
    static let coldStartDays = 14
    /// Samples inside this window after a workout are excluded from stress.
    static let postWorkoutExclusion: TimeInterval = 30 * 60
    /// Window after an intervention in which HRV recovery is measured.
    static let rewardWindow: ClosedRange<TimeInterval> = (30 * 60)...(60 * 60)
}
