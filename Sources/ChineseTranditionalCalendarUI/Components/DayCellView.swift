import SwiftUI

/// A single day cell in the monthly calendar grid.
///
/// Displays the Gregorian day number, lunar day name, and optional solar term badge.
/// Highlights today and the selected date.
public struct DayCellView: View {

    let calendarDate: CalendarDate
    let isSelected: Bool
    let configuration: CalendarConfiguration

    @Environment(\.calendarTheme) private var theme

    public init(
        calendarDate: CalendarDate,
        isSelected: Bool = false,
        configuration: CalendarConfiguration = .default
    ) {
        self.calendarDate = calendarDate
        self.isSelected = isSelected
        self.configuration = configuration
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
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Private

    /// Text shown below the day number — lunar month name on 初一, else lunar day name.
    private var lunarDisplayText: String {
        if calendarDate.isFirstOfLunarMonth {
            // Show the lunar month name on the 1st of each lunar month
            return calendarDate.lunarDayName
        }
        return calendarDate.lunarDayName
    }

    private var dayNumberColor: Color {
        if calendarDate.isToday {
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
        if calendarDate.isToday {
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
        if calendarDate.isToday {
            parts.append("Today")
        }
        return parts.joined(separator: ", ")
    }
}
