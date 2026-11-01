import SwiftUI
import ChineseAstrologyCalendar

/// A small badge showing the solar term name, used for overlay indicators.
public struct SolarTermBadge: View {

    let jieqi: Jieqi

    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarLanguage) private var language

    public init(jieqi: Jieqi) {
        self.jieqi = jieqi
    }

    public var body: some View {
        Text(jieqi.localizedName(in: language))
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(theme.solarTermColor, in: Capsule())
            .accessibilityLabel(language.string("節氣: %1$@", jieqi.localizedName(in: language)))
    }
}

#Preview {
    HStack(spacing: 8) {
        SolarTermBadge(jieqi: .springEquinox)
        SolarTermBadge(jieqi: .winterSolstice)
    }
    .padding()
}
