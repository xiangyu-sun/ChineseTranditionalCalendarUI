import SwiftUI
import ChineseAstrologyCalendar

/// Displays the Twelve Gods (建除十二神) information for a date.
///
/// Shows the god name, auspicious/inauspicious rating,
/// recommended activities (宜), and activities to avoid (忌).
public struct TwelveGodsView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        if let god = calendarDate.twelveGod {
            VStack(alignment: .leading, spacing: 8) {
                Label("建除十二神", systemImage: "star.circle")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 12) {
                    // God name
                    VStack(spacing: 4) {
                        Text(god.chinese)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(god.xiongjiL)
                            .font(.caption)
                            .foregroundStyle(auspiciousColor(for: god))
                    }
                    .frame(width: 60)

                    VStack(alignment: .leading, spacing: 6) {
                        // Meaning
                        Text(god.meaning)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryTextColor)
                            .lineLimit(2)

                        // Do
                        HStack(alignment: .top, spacing: 4) {
                            Text("宜")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(theme.auspiciousColor)
                            Text(god.do)
                                .font(.caption)
                                .foregroundStyle(theme.primaryTextColor)
                                .lineLimit(2)
                        }

                        // Don't
                        HStack(alignment: .top, spacing: 4) {
                            Text("忌")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(theme.inauspiciousColor)
                            Text(god.dontDo)
                                .font(.caption)
                                .foregroundStyle(theme.primaryTextColor)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(god.chinese), \(god.xiongjiL), 宜: \(god.do), 忌: \(god.dontDo)")
        }
    }

    private func auspiciousColor(for god: TwelveGods) -> Color {
        if god.xiongjiL.contains("黃道") {
            return theme.auspiciousColor
        } else if god.xiongjiL.contains("黑道") || god.xiongjiL.contains("凶") {
            return theme.inauspiciousColor
        }
        return theme.secondaryTextColor
    }
}
