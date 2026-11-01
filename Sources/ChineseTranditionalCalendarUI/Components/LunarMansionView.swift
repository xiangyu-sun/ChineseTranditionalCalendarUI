import SwiftUI
import ChineseAstrologyCalendar

/// Displays the 28 Lunar Mansion (二十八宿) for a date.
public struct LunarMansionView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarLanguage) private var language

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        let mansion = calendarDate.lunarMansion

        VStack(alignment: .leading, spacing: 8) {
            Label(language.string("二十八宿"), systemImage: "sparkles")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text(mansion.localizedName(in: language))
                        .font(.title2)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(mansion.fourSymbol.localizedName(in: language))
                        .font(.body)
                    Text(language.string("%1$@方", mansion.fangwei.localizedName(in: language)))
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mansion.localizedName(in: language)), \(mansion.fourSymbol.localizedName(in: language)), \(language.string("%1$@方", mansion.fangwei.localizedName(in: language)))")
    }
}

#Preview {
    LunarMansionView(calendarDate: CalendarDate(date: .now))
        .padding()
}
