import Foundation

enum HealthDataError: LocalizedError {
    case permissionDenied(String)
    case dataNotAvailable(Date)
    case validationFailed(String)
    case networkError(String)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied(let type):
            return "Please enable \(type) access in Settings"
        case .dataNotAvailable(let date):
            return "No data available for \(date.formatted())"
        case .validationFailed(let reason):
            return "Data validation failed: \(reason)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknownError(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Go to Settings → Privacy & Security → Health to enable access"
        case .dataNotAvailable:
            return "Try adding data manually or check your Health app"
        case .validationFailed:
            return "Please check your input and try again"
        case .networkError:
            return "Check your internet connection and try again"
        case .unknownError:
            return "Please try again or restart the app"
        }
    }
}
