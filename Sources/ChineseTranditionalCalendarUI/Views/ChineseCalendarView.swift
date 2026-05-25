import SwiftUI

/// The top-level container that composes all calendar views.
///
/// Provides a tabbed interface between monthly calendar, weekly strip,
/// yearly overview, and day detail views.
///
/// ## Usage
/// ```swift
/// ChineseCalendarView()
/// ```
public struct ChineseCalendarView: View {

    @State private var monthlyViewModel: MonthlyCalendarViewModel
    @State private var yearlyViewModel: YearlyCalendarViewModel
    @State private var selectedTab: CalendarTab = .monthly
    @State private var dayDetailDate: CalendarDate?

    private let configuration: CalendarConfiguration

    public init(configuration: CalendarConfiguration = .default) {
        self.configuration = configuration
        self._monthlyViewModel = State(
            wrappedValue: MonthlyCalendarViewModel(configuration: configuration)
        )
        self._yearlyViewModel = State(
            wrappedValue: YearlyCalendarViewModel(configuration: configuration)
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            tabPicker

            switch selectedTab {
            case .monthly:
                monthlyContent
            case .weekly:
                weeklyContent
            case .yearly:
                yearlyContent
            }
        }
        .sheet(item: $dayDetailDate) { selected in
            NavigationStack {
                DayDetailView(
                    calendarDate: selected,
                    configuration: configuration
                )
                .navigationTitle(selected.chineseYearMonthDate)
                #if os(iOS) || os(visionOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dayDetailDate = nil
                        }
                    }
                }
            }
            #if !os(watchOS)
            .presentationDetents([.medium, .large])
            #endif
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        Picker("View", selection: $selectedTab) {
            ForEach(CalendarTab.allCases) { tab in
                Text(tab.label).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .accessibilityLabel("Calendar view mode")
        .accessibilityHint("Switch between monthly, weekly, and yearly views")
    }

    // MARK: - Monthly

    private var monthlyContent: some View {
        VStack(spacing: 0) {
            MonthlyCalendarView(viewModel: monthlyViewModel)

            if let selected = monthlyViewModel.selectedDate {
                Divider()
                    .padding(.top, 8)

                Button {
                    dayDetailDate = selected
                } label: {
                    dayPreview(selected)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    // MARK: - Weekly

    private var weeklyContent: some View {
        VStack(spacing: 0) {
            WeekStripView(viewModel: monthlyViewModel)

            if let selected = monthlyViewModel.selectedDate {
                Divider()
                    .padding(.top, 8)

                DayDetailView(
                    calendarDate: selected,
                    configuration: configuration
                )
            } else {
                Spacer()
                Text("Select a day")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    // MARK: - Yearly

    private var yearlyContent: some View {
        ScrollView {
            YearlyOverviewView(
                viewModel: yearlyViewModel,
                onMonthSelected: { month in
                    monthlyViewModel.navigate(to: month.firstDayOfMonth)
                    selectedTab = .monthly
                }
            )
        }
    }

    // MARK: - Day Preview

    @ViewBuilder
    private func dayPreview(_ calDate: CalendarDate) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(calDate.chineseYearMonthDate)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let god = calDate.twelveGod, configuration.showTwelveGods {
                    Text("\(god.chinese) · \(god.xiongjiL)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let jieqi = calDate.jieqi, configuration.showSolarTerms {
                SolarTermBadge(jieqi: jieqi)
            }

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .accessibilityLabel("View details for \(calDate.chineseYearMonthDate)")
        .accessibilityHint("Double tap to view full almanac")
    }
}

#Preview("Default") {
    ChineseCalendarView()
}

#Preview("Minimal config") {
    ChineseCalendarView(configuration: .minimal)
}

#Preview("Traditional theme") {
    ChineseCalendarView()
        .calendarTheme(.traditional)
}
