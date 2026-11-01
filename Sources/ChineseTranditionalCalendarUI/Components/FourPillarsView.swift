import SwiftUI
import ChineseAstrologyCalendar

/// Displays the Four Pillars (四柱 / BaZi) for a given date.
///
/// Shows year, month, day, and hour pillars in a horizontal row,
/// each displaying the Ganzhi (天干地支) pair.
public struct FourPillarsView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarLanguage) private var language

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(language.string("四柱八字"), systemImage: "square.grid.4x3.fill")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                pillarColumn(title: language.string("年柱"), ganzhi: calendarDate.nianZhu)
                pillarColumn(title: language.string("月柱"), ganzhi: calendarDate.yueZhu)
                pillarColumn(title: language.string("日柱"), ganzhi: calendarDate.riZhu)
                pillarColumn(title: language.string("時柱"), ganzhi: calendarDate.shiZhu)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private func pillarColumn(title: String, ganzhi: Ganzhi?) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(theme.secondaryTextColor)

            if let ganzhi {
                Text(ganzhi.localizedName(in: language))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.primaryTextColor)
            } else {
                Text("--")
                    .font(.title3)
                    .foregroundStyle(theme.secondaryTextColor.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
    }

    private var accessibilityText: String {
        let pillars = [
            (language.string("年"), calendarDate.nianZhu),
            (language.string("月"), calendarDate.yueZhu),
            (language.string("日"), calendarDate.riZhu),
            (language.string("時"), calendarDate.shiZhu)
        ]
        return language.string("四柱: ") + pillars.map { "\($0.0)\($0.1?.localizedName(in: language) ?? "")" }.joined(separator: ", ")
    }
}

#Preview {
    FourPillarsView(calendarDate: CalendarDate(date: .now))
        .padding()
}

#Preview("Traditional theme") {
    FourPillarsView(calendarDate: CalendarDate(date: .now))
        .padding()
        .calendarTheme(.traditional)
}
