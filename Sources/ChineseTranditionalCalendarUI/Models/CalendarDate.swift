import Foundation
import ChineseAstrologyCalendar

/// A date model that bridges Foundation `Date` with Chinese traditional calendar data.
///
/// Wraps a Gregorian `Date` and lazily provides lunar day, solar term, twelve gods,
/// moon phase, Four Pillars, and other Chinese calendar information for UI consumption.
public struct CalendarDate: Identifiable, Hashable, Sendable {

    // MARK: - Stored

    /// The underlying Gregorian date (time-stripped to midnight).
    public let date: Date

    /// Gregorian calendar components (year, month, day, weekday).
    public let gregorianComponents: DateComponents

    // MARK: - Identity

    public var id: Date { date }

    // MARK: - Gregorian Convenience

    public var year: Int { gregorianComponents.year ?? 0 }
    public var month: Int { gregorianComponents.month ?? 0 }
    public var dayOfMonth: Int { gregorianComponents.day ?? 0 }
    /// 1 = Sunday, 7 = Saturday (matches `Calendar.current` weekday)
    public var weekday: Int { gregorianComponents.weekday ?? 1 }

    // MARK: - Chinese Calendar

    /// Chinese lunar day (初一 … 三十), nil when conversion fails.
    public var lunarDay: Day? { date.chineseDay() }

    /// Display name of the lunar day ("初一", "十五", etc.).
    public var lunarDayName: String { lunarDay?.name ?? "" }

    /// Whether this is the first day of a lunar month (初一).
    public var isFirstOfLunarMonth: Bool { lunarDay == .chuyi }

    /// Traditional Chinese name for the lunar month this date falls in (e.g. "正月", "二月").
    /// Prefixes with "闰" for leap months.
    public var lunarMonthName: String {
        let comps = chineseComponents
        guard let month = comps.month, month >= 1, month <= 12 else { return lunarDayName }
        let names = ["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"]
        let prefix = comps.isLeapMonth == true ? "闰" : ""
        return prefix + names[month - 1]
    }

    /// Full Chinese date string such as "甲辰年三月初一".
    public var chineseYearMonthDate: String { date.chineseYearMonthDate }

    // MARK: - Solar Term

    /// The solar term (节气) that **starts** on this date, if any.
    ///
    /// Returns non-nil only when this date is the first day of a new solar term period.
    /// Uses comparison with the previous day's solar term period to determine the boundary.
    public var jieqi: Jieqi? {
        let todayTerm = date.jieqi
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        let yesterdayTerm = yesterday.jieqi
        // If today's term differs from yesterday's, this date marks the start of a new jieqi.
        if todayTerm != yesterdayTerm {
            return todayTerm
        }
        return nil
    }

    /// The solar term period this date falls within (always non-nil).
    ///
    /// Unlike ``jieqi`` which is only non-nil on the start day,
    /// this returns the current active solar term for any date.
    public var jieqiPeriod: Jieqi? { date.jieqi }

    /// Chinese name of the solar term, or nil.
    public var jieqiName: String? { jieqi?.chineseName }

    // MARK: - Twelve Gods

    /// The Twelve Day Officer (建除十二神) for this date.
    public var twelveGod: TwelveGods? { date.twelveGod() }

    // MARK: - Moon Phase

    /// The traditional Chinese moon phase for this date.
    public var moonPhase: ChineseMoonPhase? { lunarDay?.moonPhase }

    // MARK: - Lunar Mansion

    /// The 28 Lunar Mansion (二十八宿) for this date.
    public var lunarMansion: LunarMansion { LunarMansion.lunarMansion(date: date) }

    // MARK: - Four Pillars (BaZi)

    /// Chinese calendar date components used for BaZi extraction.
    public var chineseComponents: DateComponents { date.dateComponentsFromChineseCalendar() }

    /// Year pillar (年柱).
    public var nianZhu: Ganzhi? { chineseComponents.nian }

    /// Month pillar (月柱).
    public var yueZhu: Ganzhi? { chineseComponents.yueZhu }

    /// Day pillar (日柱).
    public var riZhu: Ganzhi? { chineseComponents.riZhu }

    /// Hour pillar (时柱) — based on current time, not midnight.
    public var shiZhu: Ganzhi? { chineseComponents.shiZhu }

    /// Zodiac animal for the year.
    public var zodiac: Zodiac? { chineseComponents.zodiac }

    /// Zodiac emoji (e.g. "🐉").
    public var zodiacEmoji: String { zodiac?.emoji ?? "" }

    // MARK: - Shichen

    /// The two-hour period (时辰) at the stored date.
    public var shichen: Shichen? { date.shichen }

    // MARK: - Flags

    /// Whether this date is today in the current calendar.
    public var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Whether this date falls on a weekend.
    public var isWeekend: Bool {
        weekday == 1 || weekday == 7
    }

    // MARK: - Init

    public init(date: Date, calendar: Calendar = .current) {
        // Strip time to midnight for stable identity.
        let stripped = calendar.startOfDay(for: date)
        self.date = stripped
        self.gregorianComponents = calendar.dateComponents(
            [.year, .month, .day, .weekday],
            from: stripped
        )
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }

    public static func == (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        lhs.date == rhs.date
    }
}
