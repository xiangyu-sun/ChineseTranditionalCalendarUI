import SwiftUI
import ChineseAstrologyCalendar

/// A monthly calendar grid with Chinese traditional calendar annotations.
///
/// Displays a 7-column grid with Gregorian dates, lunar day names, and solar term indicators.
/// Supports swipe gestures for month navigation.
///
/// ## Usage
/// ```swift
/// @State var viewModel = MonthlyCalendarViewModel()
///
/// MonthlyCalendarView(viewModel: viewModel)
/// ```
public struct MonthlyCalendarView: View {

    @Bindable var viewModel: MonthlyCalendarViewModel

    public init(viewModel: MonthlyCalendarViewModel) {
        self.viewModel = viewModel
    }

    @Environment(\.calendarTheme) private var theme

    public var body: some View {
        GeometryReader { geo in
            let adapted = adaptedTheme(for: geo.size.width)

            VStack(spacing: 8) {
                MonthHeaderView(
                    month: viewModel.currentMonth,
                    onPrevious: viewModel.goToPreviousMonth,
                    onNext: viewModel.goToNextMonth,
                    onToday: viewModel.goToToday
                )

                WeekdayHeaderView(calendar: viewModel.currentMonth.calendar)

                monthGrid(theme: adapted)
            }
            .environment(\.calendarTheme, adapted)
            .background(adapted.backgroundColor)
            .gesture(swipeGesture)
            .animation(.easeInOut(duration: 0.2), value: viewModel.currentMonth)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Monthly calendar, \(viewModel.currentMonth.title)")
        }
    }

    // MARK: - Month Grid

    private func monthGrid(theme: CalendarTheme) -> some View {
        let gridDates = viewModel.currentMonth.gridDates
        let columns = Array(repeating: GridItem(.flexible(), spacing: theme.columnSpacing), count: 7)

        return LazyVGrid(columns: columns, spacing: theme.rowSpacing) {
            ForEach(Array(gridDates.enumerated()), id: \.offset) { _, calDate in
                if let calDate {
                    Button {
                        viewModel.select(calDate)
                    } label: {
                        DayCellView(
                            calendarDate: calDate,
                            isSelected: calDate == viewModel.selectedDate,
                            configuration: viewModel.configuration
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear
                        .frame(minHeight: 44)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Adaptive Theme

    /// Scales column spacing and day-cell fonts with the per-column width
    /// actually available, so a narrow `.medium` sheet on iPhone and a roomy
    /// `.large` sheet on iPad don't render with identical spacing/type sizes.
    private func adaptedTheme(for width: CGFloat) -> CalendarTheme {
        let perColumn = width / 7
        var adapted = theme
        switch perColumn {
        case ..<40:
            adapted.columnSpacing = 0
            adapted.dayNumberFont = .callout
            adapted.lunarDayFont = .caption2
        case 40 ..< 60:
            adapted.columnSpacing = 2
            adapted.dayNumberFont = .body
            adapted.lunarDayFont = .caption
        case 60 ..< 90:
            adapted.columnSpacing = 4
            adapted.dayNumberFont = .title3
            adapted.lunarDayFont = .footnote
        default:
            adapted.columnSpacing = 6
            adapted.dayNumberFont = .title2
            adapted.lunarDayFont = .subheadline
        }
        return adapted
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                if value.translation.width < -50 {
                    viewModel.goToNextMonth()
                } else if value.translation.width > 50 {
                    viewModel.goToPreviousMonth()
                }
            }
    }
}

#Preview("Default") {
    @Previewable @State var vm = MonthlyCalendarViewModel()
    MonthlyCalendarView(viewModel: vm)
}

#Preview("Minimal config") {
    @Previewable @State var vm = MonthlyCalendarViewModel(configuration: .minimal)
    MonthlyCalendarView(viewModel: vm)
}

#Preview("Traditional theme") {
    @Previewable @State var vm = MonthlyCalendarViewModel()
    MonthlyCalendarView(viewModel: vm)
        .calendarTheme(.traditional)
}
