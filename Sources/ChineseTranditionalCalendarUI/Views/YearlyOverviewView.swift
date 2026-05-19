import SwiftUI

/// A yearly overview showing 12 mini-month grids.
///
/// Each month is a compact grid showing day numbers.
/// Tapping a month can navigate to its detailed monthly view.
public struct YearlyOverviewView: View {

    @Bindable var viewModel: YearlyCalendarViewModel
    var onMonthSelected: ((CalendarMonth) -> Void)?

    @Environment(\.calendarTheme) private var theme

    public init(
        viewModel: YearlyCalendarViewModel,
        onMonthSelected: ((CalendarMonth) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onMonthSelected = onMonthSelected
    }

    #if os(watchOS)
    private let columnCount = 2
    #else
    private let columnCount = 3
    #endif

    public var body: some View {
        VStack(spacing: 12) {
            yearHeader

            let columns = Array(
                repeating: GridItem(.flexible(), spacing: 12),
                count: columnCount
            )

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.months, id: \.id) { month in
                    miniMonthView(month)
                        .onTapGesture {
                            onMonthSelected?(month)
                        }
                }
            }
            .padding(.horizontal)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.year)
    }

    // MARK: - Year Header

    private var yearHeader: some View {
        HStack {
            Button(action: viewModel.goToPreviousYear) {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Previous year")

            Spacer()

            VStack(spacing: 2) {
                Text(String(viewModel.year))
                    .font(theme.headerFont)

                if let chineseYearText = chineseYearLabel {
                    Text(chineseYearText)
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                }
            }

            Spacer()

            Button(action: viewModel.goToCurrentYear) {
                Image(systemName: "calendar.circle")
            }
            .accessibilityLabel("Current year")

            Button(action: viewModel.goToNextYear) {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("Next year")
        }
        .padding(.horizontal)
    }

    // MARK: - Mini Month

    @ViewBuilder
    private func miniMonthView(_ month: CalendarMonth) -> some View {
        VStack(spacing: 2) {
            Text(monthName(for: month.month))
                .font(.caption)
                .fontWeight(.semibold)

            miniGrid(for: month)
        }
        .padding(6)
        .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(monthName(for: month.month)) \(viewModel.year)")
    }

    @ViewBuilder
    private func miniGrid(for month: CalendarMonth) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        LazyVGrid(columns: columns, spacing: 1) {
            // Leading spaces
            ForEach(0..<month.leadingSpaces, id: \.self) { _ in
                Text("")
                    .font(.system(size: 7))
                    .frame(maxWidth: .infinity, minHeight: 10)
            }

            // Days
            ForEach(month.days) { calDate in
                Text("\(calDate.dayOfMonth)")
                    .font(.system(size: 7))
                    .foregroundStyle(miniDayColor(calDate))
                    .frame(maxWidth: .infinity, minHeight: 10)
            }
        }
    }

    private func miniDayColor(_ calDate: CalendarDate) -> Color {
        if calDate.isToday {
            return theme.accentColor
        }
        if calDate.jieqi != nil {
            return theme.solarTermColor
        }
        if calDate.isWeekend {
            return theme.weekendColor
        }
        return theme.primaryTextColor
    }

    /// Chinese year label (e.g. "甲辰年 🐉") for the currently displayed year.
    private var chineseYearLabel: String? {
        // Use a mid-year date to get the Chinese year Ganzhi.
        // Note: Chinese New Year falls in Jan/Feb, so July is safely within the year.
        var comps = DateComponents()
        comps.year = viewModel.year
        comps.month = 7
        comps.day = 1
        guard let date = Calendar.current.date(from: comps) else { return nil }
        let calDate = CalendarDate(date: date)
        var parts: [String] = []
        if let nian = calDate.nianZhu {
            parts.append(nian.formatedYear)
        }
        let emoji = calDate.zodiacEmoji
        if !emoji.isEmpty {
            parts.append(emoji)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    private func monthName(for month: Int) -> String {
        var comps = DateComponents()
        comps.year = viewModel.year
        comps.month = month
        comps.day = 1
        guard let date = Calendar.current.date(from: comps) else { return "" }
        return YearlyOverviewView.monthFormatter.string(from: date)
    }

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f
    }()
}

#Preview {
    @Previewable @State var vm = YearlyCalendarViewModel()
    ScrollView {
        YearlyOverviewView(viewModel: vm)
    }
}

#Preview("Traditional theme") {
    @Previewable @State var vm = YearlyCalendarViewModel()
    ScrollView {
        YearlyOverviewView(viewModel: vm)
    }
    .calendarTheme(.traditional)
}
