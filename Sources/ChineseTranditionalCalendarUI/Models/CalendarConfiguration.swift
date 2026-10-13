import SwiftUI
import ChineseAstrologyCalendar

/// Configuration for the calendar views.
///
/// Controls which data layers are shown, the starting weekday, and locale/calendar settings.
public struct CalendarConfiguration: Sendable {

    // MARK: - Display toggles

    /// Show lunar day names in day cells.
    public var showLunarDays: Bool

    /// Show solar term badges on relevant days.
    public var showSolarTerms: Bool

    /// Show Twelve Gods (建除) indicator.
    public var showTwelveGods: Bool

    /// Show moon phase indicator.
    public var showMoonPhase: Bool

    /// Show Four Pillars in the day detail view.
    public var showFourPillars: Bool

    /// Show Lunar Mansion (二十八宿) in day detail.
    public var showLunarMansion: Bool

    /// Show Shichen (时辰) in day detail.
    public var showShichen: Bool

    // MARK: - Special days

    /// Sources of named days (festivals, solar terms, user-defined days) to
    /// label day cells with, in priority order: when several fall on one day,
    /// the first source's day is shown.
    ///
    /// `nil` (the default) labels cells with solar terms only. When set, the
    /// sources fully replace that, so include a `JieqiSource` to keep solar
    /// terms; days of kind ``SpecialDayKind/jieqi`` still honour
    /// ``showSolarTerms``.
    ///
    /// Sources are only ever read, never mutated, so sharing them across
    /// isolation domains is safe even though the protocol isn't `Sendable`.
    nonisolated(unsafe) public var specialDaySources: [any SpecialDaySource]?

    /// The time zone whose calendar day the ``specialDaySources`` reckon in.
    /// A cell is looked up at noon of its date in this zone, so a cell always
    /// shows the named day of its own Gregorian date. `nil` uses ``calendar``'s.
    public var specialDayTimeZone: TimeZone?

    // MARK: - Calendar settings

    /// The calendar to use for Gregorian date calculations.
    public var calendar: Calendar

    /// The first day of the week (1 = Sunday, 2 = Monday).
    public var firstWeekday: Int

    // MARK: - Init

    public init(
        showLunarDays: Bool = true,
        showSolarTerms: Bool = true,
        showTwelveGods: Bool = true,
        showMoonPhase: Bool = true,
        showFourPillars: Bool = true,
        showLunarMansion: Bool = true,
        showShichen: Bool = true,
        calendar: Calendar = .current,
        firstWeekday: Int = 1,
        specialDaySources: [any SpecialDaySource]? = nil,
        specialDayTimeZone: TimeZone? = nil
    ) {
        self.showLunarDays = showLunarDays
        self.showSolarTerms = showSolarTerms
        self.showTwelveGods = showTwelveGods
        self.showMoonPhase = showMoonPhase
        self.showFourPillars = showFourPillars
        self.showLunarMansion = showLunarMansion
        self.showShichen = showShichen
        self.calendar = calendar
        self.firstWeekday = firstWeekday
        self.specialDaySources = specialDaySources
        self.specialDayTimeZone = specialDayTimeZone
    }

    /// A default configuration with all features enabled.
    public static let `default` = CalendarConfiguration()

    /// A minimal configuration showing only lunar days and solar terms.
    public static let minimal = CalendarConfiguration(
        showTwelveGods: false,
        showMoonPhase: false,
        showFourPillars: false,
        showLunarMansion: false,
        showShichen: false
    )
}
