import Foundation
import ChineseAstrologyCalendar

enum CalendarTab: String, CaseIterable, Identifiable {
    case monthly
    case weekly
    case yearly

    var id: String { rawValue }

    var label: String { label(in: .zhHant) }

    func label(in language: DisplayLanguage) -> String {
        switch self {
        case .monthly: language.string("Month")
        case .weekly: language.string("Week")
        case .yearly: language.string("Year")
        }
    }
}
