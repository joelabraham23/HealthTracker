import SwiftUI
  import HealthKit

  struct HealthPermissionsView: View {
      @StateObject private var healthManager = HealthDataManager()

      var body: some View {
          NavigationView {
              List {
                  Section("Health Data Access") {
                      PermissionRow(
                          title: "Steps",
                          icon: "figure.walk",
                          status: healthManager.getPermissionStatusText(for: HKQuantityType.quantityType(forIdentifier:
  .stepCount)!)
                      )

                      PermissionRow(
                          title: "Sleep",
                          icon: "bed.double.fill",
                          status: healthManager.getPermissionStatusText(for: HKCategoryType.categoryType(forIdentifier:
  .sleepAnalysis)!)
                      )

                      
                  }

                  Section("Actions") {
                      Button("Request Permissions Again") {
                          Task {
                              await healthManager.requestPermissions()
                          }
                      }

                      Button("Open Settings") {
                          if let url = URL(string: UIApplication.openSettingsURLString) {
                              UIApplication.shared.open(url)
                          }
                      }
                  }
              }
              .navigationTitle("Health Permissions")
          }
      }
  }

  struct PermissionRow: View {
      let title: String
      let icon: String
      let status: String

      var body: some View {
          HStack {
              Image(systemName: icon)
                  .foregroundColor(.blue)
              Text(title)
              Spacer()
              Text(status)
                  .font(.caption)
                  .foregroundColor(status == "Authorized" ? .green : .red)
          }
      }
  }
