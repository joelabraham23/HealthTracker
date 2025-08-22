//
//  HealthTrackerApp.swift
//  HealthTracker
//
//  Created by Joel Abraham on 22/8/2025.
//

import SwiftUI

@main
struct HealthTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
