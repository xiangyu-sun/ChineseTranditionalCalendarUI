import Testing
import Foundation
import ChineseAstrologyCalendar
@testable import ChineseTranditionalCalendarUI

@Suite("Day label")
struct DayLabelTests {

    private static let china = TimeZone(identifier: "Asia/Shanghai")!

    private func day(_ year: Int, _ month: Int, _ day: Int, in timeZone: TimeZone = china) -> CalendarDate {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        return CalendarDate(date: date, calendar: calendar)
    }

    private func sources(custom: [RecurringDay] = []) -> [any SpecialDaySource] {
        var lunar = Calendar(identifier: .chinese)
        lunar.timeZone = Self.china
        return [
            RecurringDaySource(days: custom, timeZone: Self.china),
            FestivalSource(converter: DayConverter(calendar: lunar), timeZone: Self.china),
            JieqiSource(timeZone: Self.china),
        ]
    }

    @Test("Without sources a festival day shows its lunar day")
    func noSourcesKeepsLunarDay() {
        let label = day(2026, 10, 18).dayLabel(configuration: .default)
        #expect(label == .lunar("初九"))
    }

    @Test("With sources 重陽節 is shown on 2026-10-18")
    func festival() {
        let config = CalendarConfiguration(specialDaySources: sources(), specialDayTimeZone: Self.china)
        #expect(day(2026, 10, 18).dayLabel(configuration: config) == .festival("重陽節"))
    }

    @Test("A custom day outranks the festival on the same day")
    func customFirst() {
        let custom = RecurringDay(name: "家宴", reckoning: .lunar, month: 9, day: 9)
        let config = CalendarConfiguration(specialDaySources: sources(custom: [custom]))
        #expect(day(2026, 10, 18).dayLabel(configuration: config) == .festival("家宴"))
    }

    @Test("Solar terms come through the sources and honour showSolarTerms")
    func solarTerm() {
        // 霜降 2026 starts on Oct 23 (China time).
        var config = CalendarConfiguration(specialDaySources: sources())
        #expect(day(2026, 10, 23).dayLabel(configuration: config) == .solarTerm("霜降"))
        config.showSolarTerms = false
        #expect(day(2026, 10, 23).dayLabel(configuration: config)?.text != "霜降")
    }

    @Test("A cell in a zone east of the sources' still reads its own date")
    func probesOwnDate() {
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let config = CalendarConfiguration(specialDaySources: sources(), specialDayTimeZone: Self.china)
        #expect(day(2026, 10, 18, in: tokyo).dayLabel(configuration: config) == .festival("重陽節"))
    }
}
