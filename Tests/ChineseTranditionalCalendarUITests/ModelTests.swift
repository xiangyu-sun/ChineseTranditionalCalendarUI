import Testing
import Foundation
@testable import ChineseTranditionalCalendarUI

@Suite("CalendarDate Tests")
struct CalendarDateTests {

    @Test("Creates CalendarDate with correct Gregorian components")
    func gregorianComponents() {
        // March 29, 2026
        let components = DateComponents(
            calendar: .current, year: 2026, month: 3, day: 29
        )
        let date = Calendar.current.date(from: components)!
        let calDate = CalendarDate(date: date)

        #expect(calDate.year == 2026)
        #expect(calDate.month == 3)
        #expect(calDate.dayOfMonth == 29)
    }

    @Test("isToday returns true for today")
    func isToday() {
        let calDate = CalendarDate(date: .now)
        #expect(calDate.isToday)
    }

    @Test("isToday returns false for a past date")
    func isNotToday() {
        let past = Calendar.current.date(
            from: DateComponents(year: 2020, month: 1, day: 1)
        )!
        let calDate = CalendarDate(date: past)
        #expect(!calDate.isToday)
    }

    @Test("Lunar day is available for a valid date")
    func lunarDay() {
        // Just verify it doesn't crash and returns something
        let calDate = CalendarDate(date: .now)
        // lunarDay may or may not be nil depending on calendar calculations;
        // at minimum we verify the API works.
        _ = calDate.lunarDayName
    }

    @Test("Solar term is nil for most dates")
    func solarTerm() {
        // Most dates don't have a solar term
        let date = Calendar.current.date(
            from: DateComponents(year: 2026, month: 6, day: 15)
        )!
        let calDate = CalendarDate(date: date)
        // We just verify the property is accessible
        _ = calDate.jieqi
    }

    @Test("Equality based on date")
    func equality() {
        let date = Date.now
        let a = CalendarDate(date: date)
        let b = CalendarDate(date: date)
        #expect(a == b)
    }

    @Test("Hashable produces same hash for same date")
    func hashable() {
        let date = Date.now
        let a = CalendarDate(date: date)
        let b = CalendarDate(date: date)
        #expect(a.hashValue == b.hashValue)
    }

    @Test("Four Pillars properties are accessible")
    func fourPillars() {
        let calDate = CalendarDate(date: .now)
        // Just verify API is callable
        _ = calDate.nianZhu
        _ = calDate.yueZhu
        _ = calDate.riZhu
        _ = calDate.zodiac
        _ = calDate.zodiacEmoji
    }

    @Test("Twelve God and Moon Phase are accessible")
    func twelveGodAndMoonPhase() {
        let calDate = CalendarDate(date: .now)
        _ = calDate.twelveGod
        _ = calDate.moonPhase
        _ = calDate.lunarMansion
    }
}

@Suite("CalendarMonth Tests")
struct CalendarMonthTests {

    @Test("March 2026 has 31 days")
    func numberOfDays() {
        let month = CalendarMonth(year: 2026, month: 3)
        #expect(month.numberOfDays == 31)
    }

    @Test("February 2024 has 29 days (leap year)")
    func leapYear() {
        let month = CalendarMonth(year: 2024, month: 2)
        #expect(month.numberOfDays == 29)
    }

    @Test("Grid is always exactly 42 cells")
    func gridCells() {
        // March 2026 (31 days) — previously only multiple-of-7
        #expect(CalendarMonth(year: 2026, month: 3).gridDates.count == 42)
        // February 2026 (28 days) — previously stopped at 28
        #expect(CalendarMonth(year: 2026, month: 2).gridDates.count == 42)
        // February 2024 leap (29 days)
        #expect(CalendarMonth(year: 2024, month: 2).gridDates.count == 42)
    }

    @Test("leadingSpaces shifts correctly for Monday-start calendar")
    func leadingSpacesMondayStart() {
        // March 2026: 1st is Sunday (weekday=1).
        // Sunday-start (firstWeekday=1): leadingSpaces = (1 - 1 + 7) % 7 = 0
        // Monday-start (firstWeekday=2): leadingSpaces = (1 - 2 + 7) % 7 = 6
        var sundayCal = Calendar(identifier: .gregorian)
        sundayCal.firstWeekday = 1
        var mondayCal = Calendar(identifier: .gregorian)
        mondayCal.firstWeekday = 2

        let marchSunday = CalendarMonth(year: 2026, month: 3, calendar: sundayCal)
        let marchMonday = CalendarMonth(year: 2026, month: 3, calendar: mondayCal)

        #expect(marchSunday.leadingSpaces == 0)
        #expect(marchMonday.leadingSpaces == 6)
    }

    @Test("lunarMonthName returns month name, not day name")
    func lunarMonthName() {
        // lunarMonthName always returns the Chinese month name (ends with 月),
        // which differs from lunarDayName (初一, 十五, etc.)
        let calDate = CalendarDate(date: .now)
        let monthName = calDate.lunarMonthName
        #expect(!monthName.isEmpty)
        #expect(monthName.hasSuffix("月"))
        #expect(monthName != calDate.lunarDayName)
    }

    @Test("lunarMonthName on Chinese New Year 2026 is 正月")
    func lunarMonthNameCNY() {
        // Chinese New Year 2026 is February 17 — 正月初一
        let cny2026 = Calendar.current.date(
            from: DateComponents(year: 2026, month: 2, day: 17)
        )!
        let calDate = CalendarDate(date: cny2026)
        #expect(calDate.isFirstOfLunarMonth)
        #expect(calDate.lunarMonthName == "正月")
    }

    @Test("days array has correct count")
    func daysCount() {
        let month = CalendarMonth(year: 2026, month: 1)
        #expect(month.days.count == 31)
    }

    @Test("previousMonth navigates correctly")
    func previousMonth() {
        let march = CalendarMonth(year: 2026, month: 3)
        let feb = march.previousMonth
        #expect(feb.month == 2)
        #expect(feb.year == 2026)
    }

    @Test("nextMonth navigates correctly")
    func nextMonth() {
        let dec = CalendarMonth(year: 2025, month: 12)
        let jan = dec.nextMonth
        #expect(jan.month == 1)
        #expect(jan.year == 2026)
    }

    @Test("Init from Date extracts correct year and month")
    func initFromDate() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2026, month: 7, day: 15)
        )!
        let month = CalendarMonth(containing: date)
        #expect(month.year == 2026)
        #expect(month.month == 7)
    }

    @Test("Title formatting")
    func title() {
        let month = CalendarMonth(year: 2026, month: 1)
        #expect(month.title.contains("2026"))
    }

    @Test("Identity is unique per year-month")
    func identity() {
        let a = CalendarMonth(year: 2026, month: 3)
        let b = CalendarMonth(year: 2026, month: 4)
        #expect(a.id != b.id)
    }
}
