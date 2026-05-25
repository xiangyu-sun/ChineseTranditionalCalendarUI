import Foundation

/// Represents a calendar month and its grid of dates.
///
/// Computes the full grid (including leading/trailing days from adjacent months)
/// needed to render a 7-column monthly calendar view.
public struct CalendarMonth: Identifiable, Hashable, Sendable {

    // MARK: - Stored

    /// The year of this month.
    public let year: Int

    /// The month number (1–12).
    public let month: Int

    /// The calendar used for date math.
    public let calendar: Calendar

    // MARK: - Identity

    public var id: String { "\(year)-\(month)" }

    // MARK: - Computed

    /// The first day of this month.
    public var firstDayOfMonth: Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        return calendar.date(from: comps) ?? .now
    }

    /// Number of days in this month.
    public var numberOfDays: Int {
        calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 30
    }

    /// Weekday of the first day (1 = Sunday … 7 = Saturday).
    public var firstWeekday: Int {
        calendar.component(.weekday, from: firstDayOfMonth)
    }

    /// Number of leading blank cells before the 1st (to align the grid).
    /// Respects `calendar.firstWeekday` so Monday-start calendars shift correctly.
    public var leadingSpaces: Int {
        let calWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (calWeekday - calendar.firstWeekday + 7) % 7
    }

    /// All `CalendarDate` values in this month (1 … numberOfDays).
    public var days: [CalendarDate] {
        (1...numberOfDays).compactMap { day -> CalendarDate? in
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = day
            guard let date = calendar.date(from: comps) else { return nil }
            return CalendarDate(date: date, calendar: calendar)
        }
    }

    /// The full grid padded to exactly 42 cells (6 rows × 7 cols).
    public var gridDates: [CalendarDate?] {
        var grid: [CalendarDate?] = Array(repeating: nil, count: leadingSpaces)
        grid.append(contentsOf: days)
        let needed = 42 - grid.count
        if needed > 0 {
            grid.append(contentsOf: Array(repeating: CalendarDate?.none, count: needed))
        }
        return grid
    }

    /// Number of rows in the grid.
    public var numberOfRows: Int {
        gridDates.count / 7
    }

    /// Formatted title, e.g. "March 2026" or localized equivalent.
    public var title: String {
        CalendarMonth.titleFormatter.string(from: firstDayOfMonth)
    }

    private static let titleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM y"
        return f
    }()

    // MARK: - Navigation

    /// The previous month.
    public var previousMonth: CalendarMonth {
        let date = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth) ?? firstDayOfMonth
        let comps = calendar.dateComponents([.year, .month], from: date)
        return CalendarMonth(year: comps.year ?? year, month: comps.month ?? 1, calendar: calendar)
    }

    /// The next month.
    public var nextMonth: CalendarMonth {
        let date = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) ?? firstDayOfMonth
        let comps = calendar.dateComponents([.year, .month], from: date)
        return CalendarMonth(year: comps.year ?? year, month: comps.month ?? 1, calendar: calendar)
    }

    // MARK: - Init

    public init(year: Int, month: Int, calendar: Calendar = .current) {
        self.year = year
        self.month = month
        self.calendar = calendar
    }

    /// Create from a `Date`, extracting year and month.
    public init(containing date: Date, calendar: Calendar = .current) {
        let comps = calendar.dateComponents([.year, .month], from: date)
        self.year = comps.year ?? 2026
        self.month = comps.month ?? 1
        self.calendar = calendar
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(month)
    }

    public static func == (lhs: CalendarMonth, rhs: CalendarMonth) -> Bool {
        lhs.year == rhs.year && lhs.month == rhs.month
    }
}
