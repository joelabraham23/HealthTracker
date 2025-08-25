import SwiftUI
import HealthKit

struct PermissionEducationView: View {
    @StateObject private var healthManager = HealthDataManager()
    @State private var showingPermissionRequest = false
    @State private var permissionGranted = false
    
    let onPermissionComplete: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Access Your Health Data")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("To calculate your health score, we need access to:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Permission items
            VStack(spacing: 20) {
                PermissionItemView(
                    icon: "figure.walk",
                    title: "Steps & Activity",
                    description: "Track your daily movement"
                )
                
                PermissionItemView(
                    icon: "bed.double.fill",
                    title: "Sleep Data",
                    description: "Monitor your sleep quality"
                )
                

            }
            
            Spacer()
            
            // Privacy assurance
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.green)
                
                Text("All data stays private and secure on your device")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        let granted = await healthManager.requestPermissions()
                        permissionGranted = granted
                        onPermissionComplete(granted)
                    }
                }) {
                    HStack {
                        if healthManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(healthManager.isLoading ? "Requesting..." : "Allow Access")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                }
                .disabled(healthManager.isLoading)
                
                Button("I'll add data manually") {
                    onPermissionComplete(false)
                }
                .foregroundColor(.secondary)
                .font(.body)
            }
        }
        .padding()
        .alert("Permission Error", isPresented: .constant(healthManager.lastError != nil)) {
            Button("OK") {
                healthManager.lastError = nil
            }
        } message: {
            if let error = healthManager.lastError {
                Text(error.errorDescription ?? "An error occurred")
            }
        }
    }
}

struct PermissionItemView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    PermissionEducationView { granted in
        print("Permission granted: \(granted)")
    }
}
