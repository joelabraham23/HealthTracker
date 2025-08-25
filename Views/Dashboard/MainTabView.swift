//
//  MainTabView.swift
//  HealthTracker
//
//  Created by Joel Abraham on 22/8/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            // Placeholder for future screens
            Text("Social Feed")
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
            
            HealthPermissionsView()
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    MainTabView()
}
