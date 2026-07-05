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
        VStack(spacing: 8) {
            if viewModel.configuration.showsHeader {
                MonthHeaderView(
                    month: viewModel.currentMonth,
                    onPrevious: viewModel.goToPreviousMonth,
                    onNext: viewModel.goToNextMonth,
                    onToday: viewModel.goToToday
                )
            }

            WeekdayHeaderView(calendar: viewModel.currentMonth.calendar)

            monthGrid
        }
        .background(theme.backgroundColor)
        .gesture(swipeGesture, isEnabled: viewModel.configuration.showsHeader)
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentMonth)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Monthly calendar, \(viewModel.currentMonth.title)")
    }

    // MARK: - Month Grid

    private var monthGrid: some View {
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
