import SwiftUI

// MARK: - CalendarTheme Adaptation

public extension CalendarTheme {
    /// Returns a copy of `self` with columnSpacing and day-cell fonts scaled to
    /// the per-column width actually available, so cramped and roomy containers
    /// (a phone `.medium` sheet vs an iPad `.large` sheet, a small vs large
    /// widget) don't render with identical spacing and type sizes.
    func adapted(toColumnWidth perColumn: CGFloat) -> CalendarTheme {
        var adapted = self
        switch perColumn {
        case ..<40:
            adapted.columnSpacing = 0
            adapted.dayNumberFont = .callout
            adapted.lunarDayFont = .caption2
        case 40 ..< 60:
            adapted.columnSpacing = 2
            adapted.dayNumberFont = .body
            adapted.lunarDayFont = .caption
        case 60 ..< 90:
            adapted.columnSpacing = 4
            adapted.dayNumberFont = .title3
            adapted.lunarDayFont = .footnote
        default:
            adapted.columnSpacing = 6
            adapted.dayNumberFont = .title2
            adapted.lunarDayFont = .subheadline
        }
        return adapted
    }
}

// MARK: - Width Measurement

private struct CalendarWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - AdaptiveCalendarColumnsModifier

private struct AdaptiveCalendarColumnsModifier: ViewModifier {
    let baseTheme: CalendarTheme

    @State private var measuredWidth: CGFloat?

    func body(content: Content) -> some View {
        content
            // Measuring via `.background` (rather than wrapping content in a
            // GeometryReader directly) matters: GeometryReader greedily fills
            // whatever space its parent offers, which would silently turn any
            // intrinsically-sized consumer of this view into a full-bleed,
            // top-pinned one. A background reader is constrained to the
            // foreground content's own size, so it measures without altering
            // layout for existing call sites.
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: CalendarWidthPreferenceKey.self, value: geo.size.width)
                }
            )
            .onPreferenceChange(CalendarWidthPreferenceKey.self) { measuredWidth = $0 }
            .environment(\.calendarTheme, adaptedTheme)
    }

    private var adaptedTheme: CalendarTheme {
        guard let measuredWidth else { return baseTheme }
        return baseTheme.adapted(toColumnWidth: measuredWidth / 7)
    }
}

public extension View {
    /// Measures this view's width and applies a `CalendarTheme` — derived from
    /// `baseTheme` — adapted to that width, to this view and its descendants.
    ///
    /// Apply to the container that wraps both `WeekdayHeaderView` and a 7-column
    /// day grid, so they read the same adapted `columnSpacing` from the
    /// environment and stay aligned, instead of each guessing independently.
    func adaptiveCalendarColumns(baseTheme: CalendarTheme) -> some View {
        modifier(AdaptiveCalendarColumnsModifier(baseTheme: baseTheme))
    }
}
