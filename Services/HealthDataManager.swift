import Foundation
import HealthKit

@MainActor
class HealthDataManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var permissionStatus: [HKObjectType: HKAuthorizationStatus] = [:]
    @Published var isLoading = false
    @Published var lastError: HealthDataError?
    
    private let requiredTypes: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
        
    ]
    
    init() {
        checkInitialPermissionStatus()
    }
    
    func requestPermissions() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            lastError = .permissionDenied("HealthKit not available on this device")
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: requiredTypes)
            await updatePermissionStatus()
            return true // Always return true after requesting - we can't know if read permission was granted
        } catch {
            lastError = .unknownError(error)
            return false
        }
    }
    
    func fetchTodaysMetrics() async throws -> DailyMetrics {
        let today = Date()
        return try await fetchMetrics(for: today)
    }
    
    func fetchMetrics(for date: Date) async throws -> DailyMetrics {
        isLoading = true
        defer { isLoading = false }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Use concurrent fetching with proper error handling
        async let stepsTask = fetchSteps(from: startOfDay, to: endOfDay)
        async let sleepTask = fetchSleep(from: startOfDay, to: endOfDay)
        
        // Don't throw on missing data - use default values
        let stepsCount = (try? await stepsTask) ?? 0
        let sleepHours = (try? await sleepTask) ?? 0.0
        
        // Track which fields had no data
        var manuallyEntered: Set<DailyMetrics.MetricType> = []
        if stepsCount == 0 { manuallyEntered.insert(.steps) }
        if sleepHours == 0 { manuallyEntered.insert(.sleep) }
        
        return DailyMetrics(
            id: UUID(),
            date: date,
            steps: stepsCount,
            sleepHours: sleepHours,
            screenTimeMinutes: 0, // Will be handled by ScreenTimeManager
            manuallyEntered: manuallyEntered,
            estimatedFields: [],
            lastUpdated: Date()
        )
    }
    
    func fetchWeeklyMetrics() async throws -> [DailyMetrics] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        var metrics: [DailyMetrics] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekAgo)!
            let dayMetrics = try await fetchMetrics(for: date)
            metrics.append(dayMetrics)
        }
        
        return metrics
    }
    
    private func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthDataError.dataNotAvailable(startDate)
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    let nsError = error as NSError
                    switch nsError.code {
                    case 5: // Permission denied
                        continuation.resume(throwing: HealthDataError.permissionDenied("Steps"))
                    case 11: // No data available - not really an error
                        continuation.resume(returning: 0)
                    default:
                        continuation.resume(throwing: HealthDataError.unknownError(error))
                    }
                } else if let sum = result?.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    continuation.resume(returning: steps)
                } else {
                    continuation.resume(returning: 0)
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchSleep(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthDataError.dataNotAvailable(startDate)
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    let nsError = error as NSError
                    switch nsError.code {
                    case 5: // Permission denied
                        continuation.resume(throwing: HealthDataError.permissionDenied("Sleep"))
                    case 11: // No data available
                        continuation.resume(returning: 0.0)
                    default:
                        continuation.resume(throwing: HealthDataError.unknownError(error))
                    }
                } else if let sleepSamples = samples as? [HKCategorySample] {
                    // Include all actual sleep stages (not "inBed" or "awake")
                    let sleepStages: Set<Int> = [
                        HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                        HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                        HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                        HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                        HKCategoryValueSleepAnalysis.asleep.rawValue // Legacy, but include for compatibility
                    ]
                    
                    let totalSleepTime = sleepSamples
                        .filter { sleepStages.contains($0.value) }
                        .reduce(0.0) { total, sample in
                            total + sample.endDate.timeIntervalSince(sample.startDate)
                        }
                    let sleepHours = totalSleepTime / 3600
                    continuation.resume(returning: sleepHours)
                } else {
                    continuation.resume(returning: 0.0)
                }
            }
            healthStore.execute(query)
        }
    }
    
    
    private func checkInitialPermissionStatus() {
        Task {
            await updatePermissionStatus()
        }
    }
    
    private func updatePermissionStatus() async {
        for type in requiredTypes {
            let status = healthStore.authorizationStatus(for: type)
            permissionStatus[type] = status
        }
    }
    
    func getPermissionStatusText(for type: HKObjectType) -> String {
        let status = healthStore.authorizationStatus(for: type)
        
        switch status {
        case .notDetermined:
            return "Not determined"
        case .sharingDenied:
            return "Denied"
        case .sharingAuthorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }
    
}
