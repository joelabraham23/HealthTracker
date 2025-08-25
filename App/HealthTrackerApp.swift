//
//  HealthTrackerApp.swift
//  HealthTracker
//
//  Created by Joel Abraham on 22/8/2025.
//

import SwiftUI
import HealthKit

@main
struct HealthTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasRequestedHealthPermissions") private var hasRequestedHealthPermissions = false

    var body: some Scene {
        WindowGroup {
            if hasRequestedHealthPermissions {
                // User has already gone through permission flow, show main app
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                // First launch - show permission education flow
                PermissionEducationView { permissionsGranted in
                    // Mark that we've requested permissions (regardless of user choice)
                    hasRequestedHealthPermissions = true
                }
            }
        }
    }
}
