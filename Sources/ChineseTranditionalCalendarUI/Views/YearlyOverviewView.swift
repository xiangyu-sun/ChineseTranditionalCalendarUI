import SwiftUI

/// A yearly overview showing 12 mini-month grids.
///
/// Each month is a compact grid showing day numbers.
/// Tapping a month can navigate to its detailed monthly view.
public struct YearlyOverviewView: View {

    @Bindable var viewModel: YearlyCalendarViewModel
    var onMonthSelected: ((CalendarMonth) -> Void)?

    @Environment(\.calendarTheme) private var theme
    @ScaledMetric(relativeTo: .caption2) private var miniCellFontSize: CGFloat = 7

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
                    Button {
                        onMonthSelected?(month)
                    } label: {
                        miniMonthView(month)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.year)
    }

    // MARK: - Year Header

    private var yearHeader: some View {
        HStack {
            Button("Previous year", systemImage: "chevron.left", action: viewModel.goToPreviousYear)
                .labelStyle(.iconOnly)

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

            Button("Current year", systemImage: "calendar.circle", action: viewModel.goToCurrentYear)
                .labelStyle(.iconOnly)

            Button("Next year", systemImage: "chevron.right", action: viewModel.goToNextYear)
                .labelStyle(.iconOnly)
        }
        .padding(.horizontal)
    }

    // MARK: - Mini Month

    @ViewBuilder
    private func miniMonthView(_ month: CalendarMonth) -> some View {
        VStack(spacing: 2) {
            Text(month.firstDayOfMonth, format: .dateTime.month(.abbreviated))
                .font(.caption)
                .fontWeight(.semibold)

            miniGrid(for: month)
        }
        .padding(6)
        .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(month.firstDayOfMonth.formatted(.dateTime.month(.wide))) \(viewModel.year)")
    }

    @ViewBuilder
    private func miniGrid(for month: CalendarMonth) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        LazyVGrid(columns: columns, spacing: 1) {
            // Leading spaces
            ForEach(0..<month.leadingSpaces, id: \.self) { _ in
                Text("")
                    .font(.system(size: miniCellFontSize))
                    .frame(maxWidth: .infinity, minHeight: 10)
            }

            // Days
            ForEach(month.days) { calDate in
                Text("\(calDate.dayOfMonth)")
                    .font(.system(size: miniCellFontSize))
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
