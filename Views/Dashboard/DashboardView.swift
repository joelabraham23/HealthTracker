//
//  DashboardView.swift
//  HealthTracker
//
//  Created by Joel Abraham on 22/8/2025.
//

import SwiftUI
import HealthKit

struct DashboardView: View {
    @StateObject private var healthManager =
HealthDataManager()
    var body: some View {
        VStack {
            Text("HealthTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Ni Hao")
            Button("Test Data Fetch") {
                Task {
                    do {
                        let metrics = try await
            healthManager.fetchTodaysMetrics()
                        print("SUCCESS: Steps: \(metrics.steps), Sleep:             \(metrics.sleepHours)")
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            }

        }
        .padding()
        .navigationTitle("Dashboard")
    }
}

#Preview {
    DashboardView()
}
