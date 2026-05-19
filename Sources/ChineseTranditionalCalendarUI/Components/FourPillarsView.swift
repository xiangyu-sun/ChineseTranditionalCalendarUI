import SwiftUI
import ChineseAstrologyCalendar

/// Displays the Four Pillars (四柱 / BaZi) for a given date.
///
/// Shows year, month, day, and hour pillars in a horizontal row,
/// each displaying the Ganzhi (天干地支) pair.
public struct FourPillarsView: View {

    let calendarDate: CalendarDate

    @Environment(\.calendarTheme) private var theme

    public init(calendarDate: CalendarDate) {
        self.calendarDate = calendarDate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("四柱八字", systemImage: "square.grid.4x3.fill")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                pillarColumn(title: "年柱", ganzhi: calendarDate.nianZhu)
                pillarColumn(title: "月柱", ganzhi: calendarDate.yueZhu)
                pillarColumn(title: "日柱", ganzhi: calendarDate.riZhu)
                pillarColumn(title: "时柱", ganzhi: calendarDate.shiZhu)
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
                Text(ganzhi.description)
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
            ("年", calendarDate.nianZhu),
            ("月", calendarDate.yueZhu),
            ("日", calendarDate.riZhu),
            ("时", calendarDate.shiZhu)
        ]
        return "四柱: " + pillars.map { "\($0.0)\($0.1?.description ?? "")" }.joined(separator: ", ")
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
