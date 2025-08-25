import Foundation

struct UserPreferences {
    let stepGoal: Int
    let sleepGoal: Double
    let screenTimeGoal: Int // in minutes
    let shareDataWithFriends: Bool
    
    static let `default` = UserPreferences(
        stepGoal: 10000,
        sleepGoal: 8.0,
        screenTimeGoal: 120, // 2 hours
        shareDataWithFriends: true
    )
    
    static func loadFromUserDefaults() -> UserPreferences {
        let stepGoal = UserDefaults.standard.object(forKey: "stepGoal") as? Int ?? 10000
        let sleepGoal = UserDefaults.standard.object(forKey: "sleepGoal") as? Double ?? 8.0
        let screenTimeGoal = UserDefaults.standard.object(forKey: "screenTimeGoal") as? Int ?? 120
        let shareDataWithFriends = UserDefaults.standard.object(forKey: "shareDataWithFriends") as? Bool ?? true
        
        return UserPreferences(
            stepGoal: stepGoal,
            sleepGoal: sleepGoal,
            screenTimeGoal: screenTimeGoal,
            shareDataWithFriends: shareDataWithFriends
        )
    }
    
    func save() {
        UserDefaults.standard.set(stepGoal, forKey: "stepGoal")
        UserDefaults.standard.set(sleepGoal, forKey: "sleepGoal")
        UserDefaults.standard.set(screenTimeGoal, forKey: "screenTimeGoal")
        UserDefaults.standard.set(shareDataWithFriends, forKey: "shareDataWithFriends")
    }
}