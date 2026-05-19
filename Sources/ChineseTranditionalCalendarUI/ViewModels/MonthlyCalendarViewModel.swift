import SwiftUI

/// Observable view model driving `MonthlyCalendarView`.
///
/// Uses the `@Observable` macro (iOS 17+) instead of `ObservableObject`.
@Observable
public final class MonthlyCalendarViewModel {

    // MARK: - Published State

    /// The currently displayed month.
    public var currentMonth: CalendarMonth

    /// The selected date, if any.
    public var selectedDate: CalendarDate?

    /// Configuration controlling which data layers are visible.
    public var configuration: CalendarConfiguration

    // MARK: - Init

    public init(
        date: Date = .now,
        configuration: CalendarConfiguration = .default
    ) {
        self.configuration = configuration
        self.currentMonth = CalendarMonth(containing: date, calendar: Self.makeCalendar(from: configuration))
    }

    // MARK: - Navigation

    /// Navigate to the previous month.
    public func goToPreviousMonth() {
        currentMonth = currentMonth.previousMonth
    }

    /// Navigate to the next month.
    public func goToNextMonth() {
        currentMonth = currentMonth.nextMonth
    }

    /// Navigate to today's month and select today.
    public func goToToday() {
        let today = Date.now
        currentMonth = CalendarMonth(containing: today, calendar: Self.makeCalendar(from: configuration))
        selectedDate = CalendarDate(date: today)
    }

    /// Navigate to a specific month containing the given date. Clears the current selection.
    public func navigate(to date: Date) {
        currentMonth = CalendarMonth(containing: date, calendar: Self.makeCalendar(from: configuration))
        selectedDate = nil
    }

    // MARK: - Private

    private static func makeCalendar(from config: CalendarConfiguration) -> Calendar {
        var cal = config.calendar
        cal.firstWeekday = config.firstWeekday
        return cal
    }

    /// Select a specific date.
    public func select(_ calendarDate: CalendarDate) {
        selectedDate = calendarDate
    }
}
