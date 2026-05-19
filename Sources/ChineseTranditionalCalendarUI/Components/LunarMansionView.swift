import SwiftUI
import ChineseAstrologyCalendar

/// Displays the 28 Lunar Mansion (二十八宿) for a date.
public struct LunarMansionView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        let mansion = calendarDate.lunarMansion

        VStack(alignment: .leading, spacing: 8) {
            Label("二十八宿", systemImage: "sparkles")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text(mansion.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(mansion.fourSymbol.rawValue)
                        .font(.body)
                    Text(mansion.fangwei.chineseCharacter + "方")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mansion.name), \(mansion.fourSymbol.rawValue), \(mansion.fangwei.chineseCharacter)方")
    }
}

#Preview {
    LunarMansionView(calendarDate: CalendarDate(date: .now))
        .padding()
}
