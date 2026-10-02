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

    /// The time zone whose calendar day this value represents. Every Chinese
    /// calendar value (lunar date, solar term, Twelve Gods, pillars) is
    /// reckoned on this time zone's calendar day, taken from the calendar
    /// passed to ``init(date:calendar:)``.
    public let timeZone: TimeZone

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
    public var lunarDay: Day? { date.chineseDay(calendar: chineseCalendar) }

    /// Display name of the lunar day ("初一", "十五", etc.).
    public var lunarDayName: String { lunarDay?.name ?? "" }

    /// Whether this is the first day of a lunar month (初一).
    public var isFirstOfLunarMonth: Bool { lunarDay == .day1 }

    /// The lunar month this date falls in, including leap months.
    public var lunarMonth: LunarMonth? { LunarMonth(components: chineseComponents) }

    /// Traditional Chinese name for the lunar month this date falls in
    /// (正月 … 十月, 冬月, 臘月), prefixed with 閏 for leap months.
    public var lunarMonthName: String {
        lunarMonth?.localizedName(in: .zhHant) ?? lunarDayName
    }

    /// The full lunar date (year stem-branch, month and day).
    public var lunarDate: LunarDate? { LunarDate(date: date, calendar: chineseCalendar) }

    /// Full Chinese date string such as "甲辰年三月初一".
    public var chineseYearMonthDate: String { lunarDate?.formatted(.yearMonthDay, in: .zhHant) ?? "" }

    // MARK: - Solar Term

    /// The solar term (節氣) that **starts** on this date, if any.
    ///
    /// Non-nil only on the first day of a solar term, reckoned on this value's
    /// calendar day in ``timeZone``: a term that begins at any time during
    /// that day starts on it. Pass a China Standard Time calendar to
    /// ``init(date:calendar:)`` to match Chinese almanacs.
    public var jieqi: Jieqi? {
        date.isJieqiDay(in: timeZone) ? date.jieqi(in: timeZone) : nil
    }

    /// The solar term period this date falls within (always non-nil).
    ///
    /// Unlike ``jieqi`` which is only non-nil on the start day,
    /// this returns the current active solar term for any date.
    public var jieqiPeriod: Jieqi? { date.jieqi(in: timeZone) }

    /// Chinese name of the solar term, or nil.
    public var jieqiName: String? { jieqi?.chineseName }

    // MARK: - Twelve Gods

    /// The Twelve Day Officer (建除十二神) for this date.
    public var twelveGod: TwelveGods? { date.twelveGod(timeZone: timeZone) }

    // MARK: - Moon Phase

    /// The traditional Chinese moon phase for this date.
    public var moonPhase: ChineseMoonPhase? { lunarDay?.moonPhase }

    // MARK: - Lunar Mansion

    /// The 28 Lunar Mansion (二十八宿) for this date.
    public var lunarMansion: LunarMansion { LunarMansion.lunarMansion(date: date) }

    // MARK: - Four Pillars (BaZi)

    /// Chinese calendar date components used for BaZi extraction.
    public var chineseComponents: DateComponents { date.dateComponentsFromChineseCalendar(chineseCalendar) }

    /// Year pillar (年柱).
    public var nianZhu: Ganzhi? { chineseComponents.nian }

    /// Month pillar (月柱).
    public var yueZhu: Ganzhi? { chineseComponents.yueZhu }

    /// Day pillar (日柱).
    public var riZhu: Ganzhi? { gregorianCalendar.dateComponents([.year, .month, .day], from: date).riZhu }

    /// Hour pillar (时柱) — reflects current moment; shiZhu changes every two hours.
    public var shiZhu: Ganzhi? { Date.now.dateComponentsFromCurrentCalendar.shiZhu }

    /// Zodiac animal for the year.
    public var zodiac: Zodiac? { chineseComponents.zodiac }

    /// Zodiac emoji (e.g. "🐉").
    public var zodiacEmoji: String { zodiac?.emoji ?? "" }

    // MARK: - Shichen

    /// The two-hour period (时辰) at the stored date.
    public var shichen: Shichen? {
        let hour = gregorianCalendar.component(.hour, from: date)
        return Shichen(dizhi: Dizhi(hourOfDay: hour), date: date, timeZone: timeZone)
    }

    // MARK: - Flags

    /// Whether this date is today, in ``timeZone``.
    public var isToday: Bool {
        gregorianCalendar.isDateInToday(date)
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
        self.timeZone = calendar.timeZone
    }

    // MARK: - Calendars

    private var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    private var chineseCalendar: Calendar {
        var calendar = Calendar(identifier: .chinese)
        calendar.timeZone = timeZone
        return calendar
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }

    public static func == (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        lhs.date == rhs.date
    }
}
