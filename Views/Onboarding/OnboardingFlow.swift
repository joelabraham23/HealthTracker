import SwiftUI

struct OnboardingFlow: View {
    @State private var currentStep: OnboardingStep = .welcome
    @State private var healthPermissionGranted = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    let onComplete: () -> Void
    
    enum OnboardingStep {
        case welcome
        case permissions
        case goalSetup
        case complete
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch currentStep {
                case .welcome:
                    WelcomeView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep = .permissions
                        }
                    }
                    
                case .permissions:
                    PermissionEducationView { granted in
                        healthPermissionGranted = granted
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep = .goalSetup
                        }
                    }
                    
                case .goalSetup:
                    GoalSetupView(healthPermissionGranted: healthPermissionGranted) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep = .complete
                        }
                    }
                    
                case .complete:
                    OnboardingCompleteView {
                        hasCompletedOnboarding = true
                        onComplete()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GoalSetupView: View {
    let healthPermissionGranted: Bool
    let onComplete: () -> Void
    
    @State private var stepGoal: Double = 10000
    @State private var sleepGoal: Double = 8.0
    @State private var screenTimeGoal: Double = 2.0
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Set Your Daily Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Personalize your health targets")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Goal settings
            VStack(spacing: 24) {
                GoalSliderView(
                    icon: "figure.walk",
                    title: "Daily Steps",
                    value: $stepGoal,
                    range: 5000...20000,
                    step: 500,
                    unit: "steps",
                    color: .green
                )
                
                GoalSliderView(
                    icon: "bed.double.fill",
                    title: "Sleep Goal",
                    value: $sleepGoal,
                    range: 6...10,
                    step: 0.5,
                    unit: "hours",
                    color: .purple
                )
                
                GoalSliderView(
                    icon: "iphone",
                    title: "Screen Time Limit",
                    value: $screenTimeGoal,
                    range: 1...6,
                    step: 0.5,
                    unit: "hours",
                    color: .orange
                )
            }
            
            Spacer()
            
            // Helper text
            Text("Don't worry about being perfect - you can adjust these anytime in Settings")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Continue button
            Button("Set My Goals") {
                // Save goals to UserDefaults or Core Data here
                saveGoals()
                onComplete()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .fontWeight(.semibold)
        }
        .padding()
    }
    
    private func saveGoals() {
        UserDefaults.standard.set(Int(stepGoal), forKey: "stepGoal")
        UserDefaults.standard.set(sleepGoal, forKey: "sleepGoal")
        UserDefaults.standard.set(screenTimeGoal * 60, forKey: "screenTimeGoal") // Convert to minutes
    }
}

struct GoalSliderView: View {
    let icon: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let color: Color
    
    private var displayValue: String {
        if unit == "steps" {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(displayValue) \(unit)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: range, step: step)
                .accentColor(color)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct OnboardingCompleteView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success animation
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("You're All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Ready to start tracking your health score?")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Get started button
            Button("View My Dashboard") {
                onComplete()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .fontWeight(.semibold)
        }
        .padding()
    }
}

#Preview {
    OnboardingFlow {
        print("Onboarding complete")
    }
}