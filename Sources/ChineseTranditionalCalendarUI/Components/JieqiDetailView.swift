import SwiftUI
import ChineseAstrologyCalendar

/// Displays the Jieqi (solar term) detail with health tips and seasonal foods.
public struct JieqiDetailView: View {

    let jieqi: Jieqi

    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarLanguage) private var language

    public init(jieqi: Jieqi) {
        self.jieqi = jieqi
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(language.string("節氣"), systemImage: "leaf.circle")
                .font(.subheadline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(jieqi.localizedName(in: language))
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text(jieqi.season.localizedName(in: language))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(theme.solarTermColor.opacity(0.2), in: Capsule())
                }

                // 72 Pentads
                Text(language.prose(jieqi.qishierHou))
                    .font(.caption)
                    .foregroundStyle(theme.secondaryTextColor)

                Divider()

                // Health tip
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "heart.text.clipboard")
                        .foregroundStyle(theme.accentColor)
                    Text(language.prose(jieqi.healthTip))
                        .font(.caption)
                }

                // Seasonal foods
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "fork.knife.circle")
                        .foregroundStyle(theme.solarTermColor)
                    Text(language.prose(jieqi.seasonalFoods))
                        .font(.caption)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(jieqi.localizedName(in: language)), \(language.prose(jieqi.healthTip))")
    }
}

#Preview {
    JieqiDetailView(jieqi: .springEquinox)
        .padding()
}

#Preview("Traditional theme") {
    JieqiDetailView(jieqi: .winterSolstice)
        .padding()
        .calendarTheme(.traditional)
}
