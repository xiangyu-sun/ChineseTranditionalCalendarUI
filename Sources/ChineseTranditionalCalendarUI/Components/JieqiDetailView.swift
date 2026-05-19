import SwiftUI
import ChineseAstrologyCalendar

/// Displays the Jieqi (solar term) detail with health tips and seasonal foods.
public struct JieqiDetailView: View {

    let jieqi: Jieqi

    @Environment(\.calendarTheme) private var theme

    public init(jieqi: Jieqi) {
        self.jieqi = jieqi
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("节气", systemImage: "leaf.circle")
                .font(.subheadline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(jieqi.chineseName)
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text(jieqi.season.chineseDescription)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(theme.solarTermColor.opacity(0.2), in: Capsule())
                }

                // 72 Pentads
                Text(jieqi.qishierHou)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryTextColor)

                Divider()

                // Health tip
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "heart.text.clipboard")
                        .foregroundStyle(theme.accentColor)
                    Text(jieqi.healthTip)
                        .font(.caption)
                }

                // Seasonal foods
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "fork.knife.circle")
                        .foregroundStyle(theme.solarTermColor)
                    Text(jieqi.seasonalFoods)
                        .font(.caption)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(jieqi.chineseName), \(jieqi.healthTip)")
    }
}

#Preview {
    JieqiDetailView(jieqi: .chunfen)
        .padding()
}

#Preview("Traditional theme") {
    JieqiDetailView(jieqi: .dongzhi)
        .padding()
        .calendarTheme(.traditional)
}
