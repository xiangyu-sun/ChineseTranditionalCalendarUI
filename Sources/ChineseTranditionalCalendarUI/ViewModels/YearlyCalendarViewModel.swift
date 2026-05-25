import SwiftUI

/// View model for `YearlyOverviewView`.
@Observable
@MainActor
public final class YearlyCalendarViewModel {

    /// The year being displayed.
    public var year: Int

    /// The calendar for date calculations.
    public var calendar: Calendar

    /// Configuration controlling display.
    public var configuration: CalendarConfiguration

    /// All 12 months of the year.
    public var months: [CalendarMonth] {
        (1...12).map { CalendarMonth(year: year, month: $0, calendar: calendar) }
    }

    public init(
        year: Int? = nil,
        calendar: Calendar = .current,
        configuration: CalendarConfiguration = .default
    ) {
        let cal = calendar
        self.year = year ?? cal.component(.year, from: .now)
        self.calendar = cal
        self.configuration = configuration
    }

    /// Navigate to the previous year.
    public func goToPreviousYear() {
        year -= 1
    }

    /// Navigate to the next year.
    public func goToNextYear() {
        year += 1
    }

    /// Navigate to the current year.
    public func goToCurrentYear() {
        year = calendar.component(.year, from: .now)
    }
}
