//
//  DashboardView.swift
//  HealthTracker
//
//  Created by Joel Abraham on 22/8/2025.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("HealthTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Ni Hao")
            // ... rest of content stays the same
        }
        .padding()
        .navigationTitle("Dashboard")
    }
}

#Preview {
    DashboardView()
}
