import SwiftUI
import ChineseAstrologyCalendar

/// A small badge showing the solar term name, used for overlay indicators.
public struct SolarTermBadge: View {

    let jieqi: Jieqi

    @Environment(\.calendarTheme) private var theme

    public init(jieqi: Jieqi) {
        self.jieqi = jieqi
    }

    public var body: some View {
        Text(jieqi.chineseName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(theme.solarTermColor, in: Capsule())
            .accessibilityLabel("节气: \(jieqi.chineseName)")
    }
}

#Preview {
    HStack(spacing: 8) {
        SolarTermBadge(jieqi: .chunfen)
        SolarTermBadge(jieqi: .dongzhi)
    }
    .padding()
}
