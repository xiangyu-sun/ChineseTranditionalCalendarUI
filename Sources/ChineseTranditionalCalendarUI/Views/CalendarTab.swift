import Foundation

enum CalendarTab: String, CaseIterable, Identifiable {
    case monthly
    case weekly
    case yearly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .monthly: "Month"
        case .weekly: "Week"
        case .yearly: "Year"
        }
    }
}
