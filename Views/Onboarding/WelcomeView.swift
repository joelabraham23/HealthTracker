import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon and branding
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("HealthTracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your Daily Health Score")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            // Value proposition
            VStack(spacing: 24) {
                Text("Track what matters, improve what counts")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                VStack(spacing: 16) {
                    FeatureRow(
                        icon: "figure.walk.circle.fill",
                        title: "Track Steps, Sleep & Screen Time",
                        subtitle: "All your health metrics in one place"
                    )
                    
                    FeatureRow(
                        icon: "target",
                        title: "Set Personal Goals",
                        subtitle: "Customize targets that work for you"
                    )
                    
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis.circle.fill",
                        title: "See Your Progress",
                        subtitle: "Simple scores and trends over time"
                    )
                }
            }
            
            Spacer()
            
            // CTA Button
            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            // Privacy note
            Text("🔒 All data stays private on your device")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView {
        print("Get Started tapped")
    }
}