import SwiftUI

/// Row of weekday abbreviation headers (Sun, Mon, … Sat).
public struct WeekdayHeaderView: View {

    @Environment(\.calendarTheme) private var theme

    /// Weekday symbols, starting from Sunday by default.
    private let symbols: [String]

    public init(calendar: Calendar = .current) {
        self.symbols = calendar.veryShortWeekdaySymbols
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
            spacing: 0
        ) {
            ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(weekdayColor(for: index))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Weekday headers")
    }

    private func weekdayColor(for index: Int) -> Color {
        // Sunday (0) and Saturday (6) are weekends
        (index == 0 || index == 6) ? theme.weekendColor : theme.secondaryTextColor
    }
}
