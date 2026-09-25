import Foundation
import HealthKit

/// Authorization, queries and background delivery for the HealthKit types in README §7.
final class HealthKitManager {
    private let store = HKHealthStore()

    static let quantityTypes: [HKQuantityTypeIdentifier] = [
        .heartRateVariabilitySDNN,
        .restingHeartRate,
        .heartRate,
        .respiratoryRate,
        .oxygenSaturation,
        .appleSleepingWristTemperature,
    ]

    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = Set(Self.quantityTypes.map { HKQuantityType($0) })
        types.insert(HKCategoryType(.sleepAnalysis))
        types.insert(HKCategoryType(.mindfulSession))
        types.insert(HKWorkoutType.workoutType())
        return types
    }

    private var shareTypes: Set<HKSampleType> {
        [HKCategoryType(.mindfulSession)]
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    /// Fetches quantity samples of the given type since `start`.
    func fetchSamples(_ identifier: HKQuantityTypeIdentifier, since start: Date) async throws -> [HKQuantitySample] {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: HKQuantityType(identifier),
                                         predicate: HKQuery.predicateForSamples(withStart: start, end: nil))],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await descriptor.result(for: store)
    }

    /// Fetches sleep analysis samples since `start`.
    func fetchSleep(since start: Date) async throws -> [HKCategorySample] {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: HKCategoryType(.sleepAnalysis),
                                         predicate: HKQuery.predicateForSamples(withStart: start, end: nil))],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await descriptor.result(for: store)
    }

    /// Fetches workouts since `start`, used to exclude exercise windows from stress.
    func fetchWorkouts(since start: Date) async throws -> [HKWorkout] {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout(HKQuery.predicateForSamples(withStart: start, end: nil))],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        return try await descriptor.result(for: store)
    }

    func enableBackgroundDelivery() async throws {
        // TODO: HKObserverQuery per type + HKAnchoredObjectQuery for incremental fetches.
        for identifier in [HKQuantityTypeIdentifier.heartRateVariabilitySDNN, .restingHeartRate] {
            try await store.enableBackgroundDelivery(for: HKQuantityType(identifier), frequency: .hourly)
        }
    }
}
