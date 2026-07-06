import SwiftUI
import ChineseAstrologyCalendar

/// A single day cell in the monthly calendar grid.
///
/// Displays the Gregorian day number, lunar day name, and optional solar term badge.
/// Highlights today and the selected date.
public struct DayCellView: View {

    let calendarDate: CalendarDate
    let isSelected: Bool
    let configuration: CalendarConfiguration
    let today: Date

    @Environment(\.calendarTheme) private var theme

    public init(
        calendarDate: CalendarDate,
        isSelected: Bool = false,
        configuration: CalendarConfiguration = .default,
        today: Date = Date()
    ) {
        self.calendarDate = calendarDate
        self.isSelected = isSelected
        self.configuration = configuration
        self.today = today
    }

    /// Whether this cell is "today", relative to the supplied `today` date rather
    /// than the system clock. Widgets must pass their timeline entry's date here:
    /// WidgetKit renders every future entry's view at delivery time, so a
    /// `Date()`/`isDateInToday` check would freeze "today" to the render date and
    /// highlight the wrong cell once a future entry is displayed.
    private var isToday: Bool {
        Calendar.current.isDate(calendarDate.date, inSameDayAs: today)
    }

    public var body: some View {
        VStack(spacing: 2) {
            // Gregorian day number
            Text("\(calendarDate.dayOfMonth)")
                .font(theme.dayNumberFont)
                .foregroundStyle(dayNumberColor)

            // Lunar day or solar term
            if let jieqi = calendarDate.jieqi, configuration.showSolarTerms {
                Text(jieqi.chineseName)
                    .font(theme.lunarDayFont)
                    .foregroundStyle(theme.solarTermColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else if configuration.showLunarDays {
                Text(lunarDisplayText)
                    .font(theme.lunarDayFont)
                    .foregroundStyle(theme.secondaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(theme.cellPadding)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(cellBackground)
        .clipShape(.rect(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Private

    /// Text shown below the day number — lunar month name on 初一, else lunar day name.
    private var lunarDisplayText: String {
        if calendarDate.isFirstOfLunarMonth {
            return calendarDate.lunarMonthName
        }
        return calendarDate.lunarDayName
    }

    private var dayNumberColor: Color {
        if isToday {
            return theme.accentColor
        }
        if calendarDate.isWeekend {
            return theme.weekendColor
        }
        return theme.primaryTextColor
    }

    private var cellBackground: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(theme.accentColor.opacity(0.15))
        }
        if isToday {
            return AnyShapeStyle(theme.accentColor.opacity(0.08))
        }
        return AnyShapeStyle(.clear)
    }

    private var accessibilityLabel: String {
        var parts = ["\(calendarDate.dayOfMonth)"]
        if let name = calendarDate.lunarDay?.name {
            parts.append(name)
        }
        if let jq = calendarDate.jieqi {
            parts.append(jq.chineseName)
        }
        if isToday {
            parts.append("Today")
        }
        return parts.joined(separator: ", ")
    }
}

#Preview("Day states") {
    let today = CalendarDate(date: .now)
    let past = CalendarDate(
        date: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15))!
    )
    // Spring Equinox 2026 — likely a solar term start
    let termDay = CalendarDate(
        date: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 20))!
    )
    return HStack(spacing: 4) {
        DayCellView(calendarDate: past)
        DayCellView(calendarDate: today, isSelected: true)
        DayCellView(calendarDate: termDay)
    }
    .padding()
}

#Preview("Traditional theme") {
    DayCellView(calendarDate: CalendarDate(date: .now), isSelected: true)
        .padding()
        .calendarTheme(.traditional)
}
