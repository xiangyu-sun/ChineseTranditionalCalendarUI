import Foundation

/// Convenience extensions on Date for calendar grid construction.
extension Date {

    /// Returns the start of the day in the given calendar.
    func startOfDay(in calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    /// Returns a date by adding a number of days.
    func adding(days: Int, in calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Returns a date by adding a number of months.
    func adding(months: Int, in calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// The weekday symbol index (0-based, starting from Sunday).
    func weekdayIndex(in calendar: Calendar = .current) -> Int {
        calendar.component(.weekday, from: self) - 1
    }
}
