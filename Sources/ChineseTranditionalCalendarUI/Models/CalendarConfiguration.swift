import SwiftUI

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
        firstWeekday: Int = 1
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
