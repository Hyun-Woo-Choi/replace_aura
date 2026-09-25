import Foundation

/// Wires HealthKit, the metrics engine, the bandit policy and the watch together.
@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var snapshot: MetricSnapshot?
    @Published private(set) var isAuthorized = false

    private let health = HealthKitManager()
    private let stress = StressCalculator()
    private let sleep = SleepScoreCalculator()
    private let policy = ContextualBandit(actions: RecoveryAction.allCases, featureCount: BanditContext.featureCount)

    func start() async {
        ConnectivityManager.shared.activate()
        do {
            try await health.requestAuthorization()
            isAuthorized = true
            // TODO: enable background delivery and start observer queries.
            await refresh()
        } catch {
            // TODO: surface authorization errors in the UI.
            isAuthorized = false
        }
    }

    func refresh() async {
        // TODO: fetch samples, update baselines, compute scores.
        // let hrv = try await health.fetchSamples(.heartRateVariabilitySDNN, since: ...)
        // snapshot = MetricSnapshot(date: .now, stressIndex: ..., sleepScore: ..., confidence: ...)
        if let snapshot {
            ConnectivityManager.shared.send(.snapshot(snapshot))
        }
    }
}
