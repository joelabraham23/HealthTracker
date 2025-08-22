
//
//  DailyMetrics.swift
//  HealthTracker
//
//  Created by Joel Abraham on 22/8/2025.
//  TEst for github

import Foundation

// MARK: - Core Health Data
struct DailyMetrics {
    let id: UUID
    let date: Date
    let steps: Int
    let sleepHours: Double
    let screenTimeMinutes: Int
    let manuallyEntered: Set<MetricType>
    let estimatedFields: Set<MetricType>
    let lastUpdated: Date
    
    enum MetricType: String, CaseIterable {
        case steps, sleep, screenTime
    }
    
    // MARK: - Validation
    func isValid() -> Bool {
        steps >= 0 && steps <= 50000 &&
        sleepHours >= 0 && sleepHours <= 16 &&
        screenTimeMinutes >= 0 && screenTimeMinutes <= 1440
    }
    
    // MARK: - Factory Methods
    static func withDefaults(for date: Date) -> DailyMetrics {
        DailyMetrics(
            id: UUID(),
            date: date,
            steps: 0,
            sleepHours: 0,
            screenTimeMinutes: 0,
            manuallyEntered: [],
            estimatedFields: [],
            lastUpdated: Date()
        )
    }
    
    // MARK: - Sample
}
