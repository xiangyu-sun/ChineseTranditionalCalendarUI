import SwiftUI

/// A compact horizontal scrollable week strip.
///
/// Shows 7 days in a horizontal row with the selected day highlighted.
/// Supports swipe navigation between weeks.
public struct WeekStripView: View {

    @Bindable var viewModel: MonthlyCalendarViewModel

    @Environment(\.calendarTheme) private var theme

    public init(viewModel: MonthlyCalendarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 8) {
            weekdayLabels

            HStack(spacing: 4) {
                ForEach(currentWeekDates) { calDate in
                    weekDayCell(calDate)
                        .onTapGesture {
                            viewModel.select(calDate)
                        }
                }
            }
            .padding(.horizontal)
            .gesture(swipeGesture)
            .animation(.easeInOut(duration: 0.2), value: referenceDate)
        }
    }

    // MARK: - Week Dates

    /// The 7 dates of the current week based on the selected date or the displayed month's first day.
    private var currentWeekDates: [CalendarDate] {
        let calendar = viewModel.currentMonth.calendar
        let anchor = viewModel.selectedDate?.date ?? viewModel.currentMonth.firstDayOfMonth
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: anchor) else {
            return []
        }
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) else {
                return nil
            }
            return CalendarDate(date: date, calendar: calendar)
        }
    }

    private var referenceDate: Date {
        viewModel.selectedDate?.date ?? viewModel.currentMonth.firstDayOfMonth
    }

    // MARK: - Sub-views

    private var weekdayLabels: some View {
        HStack(spacing: 4) {
            ForEach(
                Array(viewModel.currentMonth.calendar.veryShortWeekdaySymbols.enumerated()),
                id: \.offset
            ) { index, symbol in
                Text(symbol)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        (index == 0 || index == 6) ? theme.weekendColor : theme.secondaryTextColor
                    )
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func weekDayCell(_ calDate: CalendarDate) -> some View {
        let isSelected = calDate == viewModel.selectedDate
        VStack(spacing: 2) {
            Text("\(calDate.dayOfMonth)")
                .font(.callout)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundStyle(dayColor(calDate, isSelected: isSelected))

            if let jieqi = calDate.jieqi, viewModel.configuration.showSolarTerms {
                Text(jieqi.chineseName)
                    .font(.system(size: 8))
                    .foregroundStyle(theme.solarTermColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } else if viewModel.configuration.showLunarDays {
                Text(calDate.lunarDayName)
                    .font(.system(size: 8))
                    .foregroundStyle(theme.secondaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(
            isSelected
                ? AnyShapeStyle(theme.accentColor.opacity(0.15))
                : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 8)
        )
        .overlay {
            if calDate.isToday && !isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(theme.accentColor.opacity(0.5), lineWidth: 1)
            }
        }
        .accessibilityLabel("\(calDate.dayOfMonth), \(calDate.lunarDayName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAddTraits(.isButton)
    }

    private func dayColor(_ calDate: CalendarDate, isSelected: Bool) -> Color {
        if isSelected { return theme.accentColor }
        if calDate.isToday { return theme.accentColor }
        if calDate.isWeekend { return theme.weekendColor }
        return theme.primaryTextColor
    }

    // MARK: - Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                let calendar = viewModel.currentMonth.calendar
                let anchor = viewModel.selectedDate?.date ?? viewModel.currentMonth.firstDayOfMonth
                if value.translation.width < -50 {
                    if let next = calendar.date(byAdding: .weekOfYear, value: 1, to: anchor) {
                        viewModel.navigate(to: next)
                        viewModel.select(CalendarDate(date: next, calendar: calendar))
                    }
                } else if value.translation.width > 50 {
                    if let prev = calendar.date(byAdding: .weekOfYear, value: -1, to: anchor) {
                        viewModel.navigate(to: prev)
                        viewModel.select(CalendarDate(date: prev, calendar: calendar))
                    }
                }
            }
    }
}

#Preview {
    @Previewable @State var vm = MonthlyCalendarViewModel()
    WeekStripView(viewModel: vm)
        .padding()
}
