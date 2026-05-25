import SwiftUI

/// Header showing the month title, year, and navigation arrows.
public struct MonthHeaderView: View {

    let month: CalendarMonth
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    @Environment(\.calendarTheme) private var theme

    public init(
        month: CalendarMonth,
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onToday: @escaping () -> Void
    ) {
        self.month = month
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onToday = onToday
    }

    public var body: some View {
        HStack {
            Button("Previous month", systemImage: "chevron.left", action: onPrevious)
                .labelStyle(.iconOnly)
                .imageScale(.large)

            Spacer()

            VStack(spacing: 2) {
                Text(month.title)
                    .font(theme.headerFont)

                // Chinese year info for the first day
                if let firstDay = month.days.first {
                    Text(chineseYearText(for: firstDay))
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                }
            }
            .accessibilityElement(children: .combine)

            Spacer()

            Button("Go to today", systemImage: "calendar.circle", action: onToday)
                .labelStyle(.iconOnly)
                .imageScale(.large)

            Button("Next month", systemImage: "chevron.right", action: onNext)
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func chineseYearText(for date: CalendarDate) -> String {
        var parts: [String] = []
        if let nian = date.nianZhu {
            parts.append(nian.formatedYear)
        }
        let emoji = date.zodiacEmoji
        if !emoji.isEmpty {
            parts.append(emoji)
        }
        return parts.joined(separator: " ")
    }
}

#Preview {
    MonthHeaderView(
        month: CalendarMonth(containing: .now),
        onPrevious: {},
        onNext: {},
        onToday: {}
    )
}
