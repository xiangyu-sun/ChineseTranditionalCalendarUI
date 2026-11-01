import SwiftUI
import ChineseAstrologyCalendar

/// Displays the Twelve Gods (建除十二神) information for a date.
///
/// Shows the god name, auspicious/inauspicious rating,
/// recommended activities (宜), and activities to avoid (忌).
public struct TwelveGodsView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarLanguage) private var language

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        if let god = calendarDate.twelveGod {
            VStack(alignment: .leading, spacing: 8) {
                Label(language.string("建除十二神"), systemImage: "star.circle")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 12) {
                    // God name
                    VStack(spacing: 4) {
                        Text(god.localizedName(in: language))
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(language.prose(god.xiongjiL))
                            .font(.caption)
                            .foregroundStyle(auspiciousColor(for: god))
                    }
                    .frame(width: 60)

                    VStack(alignment: .leading, spacing: 6) {
                        // Meaning
                        Text(language.prose(god.meaning))
                            .font(.caption)
                            .foregroundStyle(theme.secondaryTextColor)
                            .lineLimit(2)

                        // Do
                        HStack(alignment: .top, spacing: 4) {
                            Text(language.string("宜"))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(theme.auspiciousColor)
                            Text(language.prose(god.do))
                                .font(.caption)
                                .foregroundStyle(theme.primaryTextColor)
                                .lineLimit(2)
                        }

                        // Don't
                        HStack(alignment: .top, spacing: 4) {
                            Text(language.string("忌"))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(theme.inauspiciousColor)
                            Text(language.prose(god.dontDo))
                                .font(.caption)
                                .foregroundStyle(theme.primaryTextColor)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(language.string("%1$@, %2$@, 宜: %3$@, 忌: %4$@", god.localizedName(in: language), language.prose(god.xiongjiL), language.prose(god.do), language.prose(god.dontDo)))
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

#Preview {
    TwelveGodsView(calendarDate: CalendarDate(date: .now))
        .padding()
}

#Preview("Traditional theme") {
    TwelveGodsView(calendarDate: CalendarDate(date: .now))
        .padding()
        .calendarTheme(.traditional)
}
