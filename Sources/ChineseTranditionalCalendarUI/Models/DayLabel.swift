import Foundation
import ChineseAstrologyCalendar

/// What a day cell shows under its Gregorian day number.
enum DayLabel: Equatable {
    /// A festival or user-defined day from ``CalendarConfiguration/specialDaySources``.
    case festival(String)
    /// A solar term starting on this day.
    case solarTerm(String)
    /// The lunar day (or month, on 初一) name.
    case lunar(String)

    var text: String {
        switch self {
        case .festival(let text), .solarTerm(let text), .lunar(let text): text
        }
    }
}

extension CalendarDate {

    /// The first special day from `sources` falling on this value's Gregorian
    /// date, reckoned in `timeZone` (defaults to ``timeZone``).
    ///
    /// The lookup instant is noon of this date in `timeZone`, so the result is
    /// the named day of the cell's own date even when `timeZone` differs from
    /// the calendar the grid was built with.
    public func specialDay(
        from sources: [any SpecialDaySource],
        timeZone: TimeZone? = nil,
        includingSolarTerms: Bool = true
    ) -> SpecialDay? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone ?? self.timeZone
        var components = DateComponents(year: year, month: month, day: dayOfMonth)
        components.hour = 12
        guard let probe = calendar.date(from: components) else { return nil }
        for source in sources {
            let days = source.specialDays(on: probe)
            if let day = days.first(where: { includingSolarTerms || $0.kind != .jieqi }) {
                return day
            }
        }
        return nil
    }

    /// Text shown below the day number when no named day applies — the lunar
    /// month name on 初一, else the lunar day name.
    var lunarDisplayText: String {
        isFirstOfLunarMonth ? lunarMonthName : lunarDayName
    }

    /// The cell label under `configuration`, by priority: special day (in the
    /// sources' order) > solar term > lunar day. `nil` when nothing is enabled.
    func dayLabel(configuration: CalendarConfiguration, lunarText: String? = nil) -> DayLabel? {
        if let sources = configuration.specialDaySources {
            if let day = specialDay(
                from: sources,
                timeZone: configuration.specialDayTimeZone,
                includingSolarTerms: configuration.showSolarTerms
            ) {
                return day.kind == .jieqi ? .solarTerm(day.name) : .festival(day.name)
            }
        } else if configuration.showSolarTerms, let jieqi {
            return .solarTerm(jieqi.chineseName)
        }
        return configuration.showLunarDays ? .lunar(lunarText ?? lunarDisplayText) : nil
    }
}
