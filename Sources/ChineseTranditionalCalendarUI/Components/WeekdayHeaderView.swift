import SwiftUI

/// Row of weekday abbreviation headers (Sun, Mon, … Sat).
/// Rotates to respect `calendar.firstWeekday`.
public struct WeekdayHeaderView: View {

    @Environment(\.calendarTheme) private var theme

    private let symbols: [String]
    private let weekendIndices: Set<Int>

    public init(calendar: Calendar = .current) {
        let all = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        if offset == 0 {
            symbols = all
        } else {
            symbols = Array(all[offset...] + all[..<offset])
        }
        // After rotation: Sunday was at original index 0, Saturday at 6.
        let sunIndex = (7 - offset) % 7
        let satIndex = (6 + 7 - offset) % 7
        weekendIndices = [sunIndex, satIndex]
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
                    .foregroundStyle(weekendIndices.contains(index) ? theme.weekendColor : theme.secondaryTextColor)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Weekday headers")
    }
}

#Preview("Sunday start") {
    WeekdayHeaderView()
}

#Preview("Monday start") {
    var cal = Calendar.current
    cal.firstWeekday = 2
    return WeekdayHeaderView(calendar: cal)
}
