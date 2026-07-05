import SwiftUI
import ChineseAstrologyCalendar

/// Displays moon phase information for a date.
///
/// Shows the traditional Chinese moon phase name and a symbolic representation.
public struct MoonPhaseView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        if let phase = calendarDate.moonPhase, let lunarDay = calendarDate.lunarDay {
            VStack(alignment: .leading, spacing: 8) {
                Label("月相", systemImage: "moon.circle")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 12) {
                    Text(moonEmoji(for: phase))
                        .font(.system(size: 40))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(phase.modernChineseName(lunarDay))
                            .font(.body)
                            .fontWeight(.medium)
                        if phase.acientChineseName(lunarDay) != phase.modernChineseName(lunarDay) {
                            Text(phase.acientChineseName(lunarDay))
                                .font(.caption)
                                .foregroundStyle(theme.secondaryTextColor)
                        }
                        Text(lunarDay.name)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryTextColor)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("月相: \(phase.modernChineseName(lunarDay)), \(lunarDay.name)")
        }
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
