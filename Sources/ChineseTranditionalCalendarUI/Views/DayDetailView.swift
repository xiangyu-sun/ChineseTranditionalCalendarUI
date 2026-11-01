import SwiftUI
import ChineseAstrologyCalendar

/// Full almanac detail view for a single date.
///
/// Shows Chinese date header, Four Pillars, Twelve Gods (宜/忌),
/// solar term details, moon phase, and Lunar Mansion.
///
/// ## Usage
/// ```swift
/// DayDetailView(calendarDate: calendarDate)
/// ```
public struct DayDetailView: View {

    let calendarDate: CalendarDate
    let configuration: CalendarConfiguration

    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarLanguage) private var language

    public init(
        calendarDate: CalendarDate,
        configuration: CalendarConfiguration = .default
    ) {
        self.calendarDate = calendarDate
        self.configuration = configuration
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                dateHeader

                Divider()

                if configuration.showFourPillars {
                    FourPillarsView(calendarDate: calendarDate)
                    Divider()
                }

                if configuration.showTwelveGods {
                    TwelveGodsView(calendarDate: calendarDate)
                    Divider()
                }

                if let jieqi = calendarDate.jieqi, configuration.showSolarTerms {
                    JieqiDetailView(jieqi: jieqi)
                    Divider()
                }

                if configuration.showMoonPhase {
                    MoonPhaseView(calendarDate: calendarDate)
                    Divider()
                }

                if configuration.showLunarMansion {
                    LunarMansionView(calendarDate: calendarDate)
                }

                if configuration.showShichen, let shichen = calendarDate.shichen {
                    Divider()
                    shichenSection(shichen)
                }
            }
            .padding()
        }
        .background(theme.backgroundColor)
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        VStack(spacing: 4) {
            // Gregorian date
            Text(calendarDate.date, format: .dateTime.day().month(.wide).year())
                .font(.title2)
                .bold()

            // Chinese calendar date
            Text(calendarDate.chineseYearMonthDate(in: language))
                .font(.headline)
                .foregroundStyle(theme.secondaryTextColor)

            // Zodiac
            if let zodiac = calendarDate.zodiac {
                Text(language.string("%1$@ %2$@年", zodiac.emoji, zodiac.localizedName(in: language)))
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryTextColor)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(language.string("Date")): \(calendarDate.date.formatted(date: .long, time: .omitted)), \(calendarDate.chineseYearMonthDate(in: language))")
    }

    // MARK: - Shichen Section

    @ViewBuilder
    private func shichenSection(_ shichen: Shichen) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(language.string("時辰"), systemImage: "clock.circle")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text(language.string("%1$@時", shichen.dizhi.localizedName(in: language)))
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(language.prose(shichen.dizhi.aliasName))
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let hourRange = shichen.dizhi.formattedHourRange {
                        Text(hourRange)
                            .font(.caption)
                    }
                    Text(language.string("刻: %1$@", shichen.localizedKeSpellOut(in: language)))
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                    Text(language.string("經絡: %1$@", language.prose(shichen.dizhi.organReference)))
                        .font(.caption)
                        .foregroundStyle(theme.secondaryTextColor)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(language.string("時辰: %1$@, %2$@", language.string("%1$@時", shichen.dizhi.localizedName(in: language)), language.prose(shichen.dizhi.aliasName)))
    }
}

#Preview("Default config") {
    DayDetailView(calendarDate: CalendarDate(date: .now))
}

#Preview("Minimal config") {
    DayDetailView(
        calendarDate: CalendarDate(date: .now),
        configuration: .minimal
    )
}

#Preview("Traditional theme") {
    DayDetailView(calendarDate: CalendarDate(date: .now))
        .calendarTheme(.traditional)
}
