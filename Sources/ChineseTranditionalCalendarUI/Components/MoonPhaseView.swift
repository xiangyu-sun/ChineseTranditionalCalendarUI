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
                        Text(phase.acientChineseName(lunarDay))
                            .font(.caption)
                            .foregroundStyle(theme.secondaryTextColor)
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
        case .朔: return "🌑"
        case .蛾眉月: return "🌒"
        case .上弦月: return "🌓"
        case .漸盈凸月: return "🌔"
        case .望: return "🌕"
        case .漸虧凸月: return "🌖"
        case .下弦月: return "🌗"
        case .殘月: return "🌘"
        case .晦: return "🌑"
        }
    }
}

#Preview {
    MoonPhaseView(calendarDate: CalendarDate(date: .now))
        .padding()
}
