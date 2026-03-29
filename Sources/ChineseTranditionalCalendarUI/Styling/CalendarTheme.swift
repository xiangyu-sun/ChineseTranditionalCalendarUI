import SwiftUI

/// Theme for customizing calendar appearance.
///
/// Provides colors, fonts, and spacing that views use for rendering.
/// Passed through the SwiftUI environment.
public struct CalendarTheme: Sendable {

    // MARK: - Colors

    /// Primary text color for day numbers.
    public var primaryTextColor: Color

    /// Secondary text color for lunar dates and labels.
    public var secondaryTextColor: Color

    /// Accent color for today indicator and selection.
    public var accentColor: Color

    /// Background color for the calendar.
    public var backgroundColor: Color

    /// Color for weekend day numbers.
    public var weekendColor: Color

    /// Color for solar term badges.
    public var solarTermColor: Color

    /// Color for auspicious indicators (黄道).
    public var auspiciousColor: Color

    /// Color for inauspicious indicators (黑道).
    public var inauspiciousColor: Color

    // MARK: - Fonts

    /// Font for Gregorian day numbers.
    public var dayNumberFont: Font

    /// Font for lunar day text.
    public var lunarDayFont: Font

    /// Font for header titles.
    public var headerFont: Font

    // MARK: - Spacing

    /// Vertical spacing between rows in the grid.
    public var rowSpacing: CGFloat

    /// Horizontal spacing between columns.
    public var columnSpacing: CGFloat

    /// Padding inside each day cell.
    public var cellPadding: CGFloat

    // MARK: - Init

    public init(
        primaryTextColor: Color = .primary,
        secondaryTextColor: Color = .secondary,
        accentColor: Color = .red,
        backgroundColor: Color = .clear,
        weekendColor: Color = .red.opacity(0.7),
        solarTermColor: Color = .green,
        auspiciousColor: Color = .yellow,
        inauspiciousColor: Color = .gray,
        dayNumberFont: Font = .body,
        lunarDayFont: Font = .caption2,
        headerFont: Font = .headline,
        rowSpacing: CGFloat = 4,
        columnSpacing: CGFloat = 0,
        cellPadding: CGFloat = 4
    ) {
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.weekendColor = weekendColor
        self.solarTermColor = solarTermColor
        self.auspiciousColor = auspiciousColor
        self.inauspiciousColor = inauspiciousColor
        self.dayNumberFont = dayNumberFont
        self.lunarDayFont = lunarDayFont
        self.headerFont = headerFont
        self.rowSpacing = rowSpacing
        self.columnSpacing = columnSpacing
        self.cellPadding = cellPadding
    }

    /// The default theme.
    public static let `default` = CalendarTheme()

    /// A traditional Chinese red-and-gold theme.
    public static let traditional = CalendarTheme(
        primaryTextColor: .primary,
        secondaryTextColor: .brown,
        accentColor: .red,
        backgroundColor: .clear,
        weekendColor: .red,
        solarTermColor: .green,
        auspiciousColor: .yellow,
        inauspiciousColor: .gray,
        dayNumberFont: .body.weight(.medium),
        lunarDayFont: .caption2,
        headerFont: .headline.weight(.bold),
        rowSpacing: 6,
        columnSpacing: 2,
        cellPadding: 6
    )
}

// MARK: - Environment Key

public extension EnvironmentValues {
    /// The current calendar theme.
    @Entry var calendarTheme: CalendarTheme = .default
}

public extension View {
    /// Applies a custom calendar theme to this view and its descendants.
    func calendarTheme(_ theme: CalendarTheme) -> some View {
        environment(\.calendarTheme, theme)
    }
}
