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
            MonthHeaderView(
                month: viewModel.currentMonth,
                onPrevious: viewModel.goToPreviousMonth,
                onNext: viewModel.goToNextMonth,
                onToday: viewModel.goToToday
            )

            WeekdayHeaderView(calendar: viewModel.currentMonth.calendar)

            MonthGridView(viewModel: viewModel)
        }
        .adaptiveCalendarColumns(baseTheme: theme)
        .background(theme.backgroundColor)
        .gesture(swipeGesture)
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentMonth)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Monthly calendar, \(viewModel.currentMonth.title)")
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

// MARK: - MonthGridView

/// The 7-column day grid, split out into its own view (rather than a computed
/// property on `MonthlyCalendarView`) so it reads `calendarTheme` fresh from
/// its own environment — matching `WeekdayHeaderView` and `DayCellView`. That's
/// what lets `.adaptiveCalendarColumns` (applied on an ancestor) reach it.
private struct MonthGridView: View {
    @Bindable var viewModel: MonthlyCalendarViewModel

    @Environment(\.calendarTheme) private var theme

    var body: some View {
        let gridDates = viewModel.currentMonth.gridDates
        let columns = Array(repeating: GridItem(.flexible(), spacing: theme.columnSpacing), count: 7)

        LazyVGrid(columns: columns, spacing: theme.rowSpacing) {
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
