import SwiftUI
import ChineseAstrologyCalendar

/// Displays moon phase information for a date.
///
/// Shows the traditional Chinese moon phase name and a symbolic representation.
public struct MoonPhaseView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarLanguage) private var language

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        if let phase = calendarDate.moonPhase, let lunarDay = calendarDate.lunarDay {
            VStack(alignment: .leading, spacing: 8) {
                Label(language.string("月相"), systemImage: "moon.circle")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 12) {
                    Text(moonEmoji(for: phase))
                        .font(.system(size: 40))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(phaseName(phase, lunarDay))
                            .font(.body)
                            .fontWeight(.medium)
                        if phase.acientChineseName(lunarDay) != phase.modernChineseName(lunarDay) {
                            Text(language.prose(phase.acientChineseName(lunarDay)))
                                .font(.caption)
                                .foregroundStyle(theme.secondaryTextColor)
                        }
                        Text(lunarDay.localizedName(in: language))
                            .font(.caption)
                            .foregroundStyle(theme.secondaryTextColor)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(language.string("月相: %1$@, %2$@", phaseName(phase, lunarDay), lunarDay.localizedName(in: language)))
        }
    }

    private func phaseName(_ phase: ChineseMoonPhase, _ lunarDay: Day) -> String {
        language == .zhHant ? phase.modernChineseName(lunarDay) : phase.localizedName(in: language)
    }

    private func moonEmoji(for phase: ChineseMoonPhase) -> String {
        switch phase {
        case .newMoon: return "🌑"
        case .waxingCrescent: return "🌒"
        case .firstQuarter: return "🌓"
        case .waxingGibbous: return "🌔"
        case .fullMoon: return "🌕"
        case .waningGibbous: return "🌖"
        case .lastQuarter: return "🌗"
        case .waningCrescent: return "🌘"
        case .darkMoon: return "🌑"
        }
    }
}

#Preview {
    MoonPhaseView(calendarDate: CalendarDate(date: .now))
        .padding()
}
