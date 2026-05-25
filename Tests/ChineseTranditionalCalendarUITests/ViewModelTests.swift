import Testing
import Foundation
@testable import ChineseTranditionalCalendarUI

// MARK: - MonthlyCalendarViewModel Tests

@Suite("MonthlyCalendarViewModel Tests")
@MainActor
struct MonthlyCalendarViewModelTests {

    @Test("Initializes with current month")
    func defaultInit() {
        let vm = MonthlyCalendarViewModel()
        let now = Calendar.current.dateComponents([.year, .month], from: .now)
        #expect(vm.currentMonth.year == now.year)
        #expect(vm.currentMonth.month == now.month)
        #expect(vm.selectedDate == nil)
    }

    @Test("Initializes with a specific date")
    func initWithDate() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2025, month: 6, day: 15)
        )!
        let vm = MonthlyCalendarViewModel(date: date)
        #expect(vm.currentMonth.year == 2025)
        #expect(vm.currentMonth.month == 6)
    }

    @Test("goToNextMonth advances by one month")
    func goToNextMonth() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2026, month: 3, day: 1)
        )!
        let vm = MonthlyCalendarViewModel(date: date)
        vm.goToNextMonth()
        #expect(vm.currentMonth.month == 4)
        #expect(vm.currentMonth.year == 2026)
    }

    @Test("goToPreviousMonth goes back one month")
    func goToPreviousMonth() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2026, month: 3, day: 1)
        )!
        let vm = MonthlyCalendarViewModel(date: date)
        vm.goToPreviousMonth()
        #expect(vm.currentMonth.month == 2)
        #expect(vm.currentMonth.year == 2026)
    }

    @Test("goToNextMonth wraps December to January of next year")
    func nextMonthWrap() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2025, month: 12, day: 1)
        )!
        let vm = MonthlyCalendarViewModel(date: date)
        vm.goToNextMonth()
        #expect(vm.currentMonth.month == 1)
        #expect(vm.currentMonth.year == 2026)
    }

    @Test("goToPreviousMonth wraps January to December of previous year")
    func previousMonthWrap() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2026, month: 1, day: 1)
        )!
        let vm = MonthlyCalendarViewModel(date: date)
        vm.goToPreviousMonth()
        #expect(vm.currentMonth.month == 12)
        #expect(vm.currentMonth.year == 2025)
    }

    @Test("select sets selectedDate")
    func selectDate() {
        let vm = MonthlyCalendarViewModel()
        let calDate = CalendarDate(date: .now)
        vm.select(calDate)
        #expect(vm.selectedDate == calDate)
    }

    @Test("goToToday navigates to current month and selects today")
    func goToToday() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2020, month: 6, day: 1)
        )!
        let vm = MonthlyCalendarViewModel(date: date)
        #expect(vm.currentMonth.year == 2020)

        vm.goToToday()

        let now = Calendar.current.dateComponents([.year, .month], from: .now)
        #expect(vm.currentMonth.year == now.year)
        #expect(vm.currentMonth.month == now.month)
        #expect(vm.selectedDate != nil)
        #expect(vm.selectedDate?.isToday == true)
    }

    @Test("navigate(to:) moves to arbitrary date's month")
    func navigateToDate() {
        let vm = MonthlyCalendarViewModel()
        let target = Calendar.current.date(
            from: DateComponents(year: 2024, month: 8, day: 20)
        )!
        vm.navigate(to: target)
        #expect(vm.currentMonth.year == 2024)
        #expect(vm.currentMonth.month == 8)
    }

    @Test("navigate(to:) clears selectedDate")
    func navigateClearsSelection() {
        let vm = MonthlyCalendarViewModel()
        vm.select(CalendarDate(date: .now))
        #expect(vm.selectedDate != nil)

        let other = Calendar.current.date(
            from: DateComponents(year: 2025, month: 6, day: 1)
        )!
        vm.navigate(to: other)
        #expect(vm.selectedDate == nil)
    }

    @Test("firstWeekday from config is applied to calendar grid")
    func firstWeekdayPropagated() {
        // March 2026: 1st is Sunday.
        // Monday-start config → leadingSpaces should be 6.
        let date = Calendar.current.date(
            from: DateComponents(year: 2026, month: 3, day: 1)
        )!
        let mondayConfig = CalendarConfiguration(firstWeekday: 2)
        let vm = MonthlyCalendarViewModel(date: date, configuration: mondayConfig)
        #expect(vm.currentMonth.calendar.firstWeekday == 2)
        #expect(vm.currentMonth.leadingSpaces == 6)
    }

    @Test("Configuration is passed through correctly")
    func configuration() {
        let config = CalendarConfiguration.minimal
        let vm = MonthlyCalendarViewModel(configuration: config)
        #expect(vm.configuration.showFourPillars == false)
        #expect(vm.configuration.showLunarDays == true)
        #expect(vm.configuration.showSolarTerms == true)
    }
}

// MARK: - YearlyCalendarViewModel Tests

@Suite("YearlyCalendarViewModel Tests")
@MainActor
struct YearlyCalendarViewModelTests {

    @Test("Initializes with current year by default")
    func defaultInit() {
        let vm = YearlyCalendarViewModel()
        let currentYear = Calendar.current.component(.year, from: .now)
        #expect(vm.year == currentYear)
    }

    @Test("Initializes with a specific year")
    func initWithYear() {
        let vm = YearlyCalendarViewModel(year: 2024)
        #expect(vm.year == 2024)
    }

    @Test("months returns exactly 12 months")
    func monthsCount() {
        let vm = YearlyCalendarViewModel(year: 2026)
        #expect(vm.months.count == 12)
    }

    @Test("months have correct month numbers 1-12")
    func monthNumbers() {
        let vm = YearlyCalendarViewModel(year: 2026)
        for (index, month) in vm.months.enumerated() {
            #expect(month.month == index + 1)
            #expect(month.year == 2026)
        }
    }

    @Test("goToNextYear increments year")
    func goToNextYear() {
        let vm = YearlyCalendarViewModel(year: 2026)
        vm.goToNextYear()
        #expect(vm.year == 2027)
    }

    @Test("goToPreviousYear decrements year")
    func goToPreviousYear() {
        let vm = YearlyCalendarViewModel(year: 2026)
        vm.goToPreviousYear()
        #expect(vm.year == 2025)
    }

    @Test("goToCurrentYear resets to current year")
    func goToCurrentYear() {
        let vm = YearlyCalendarViewModel(year: 1999)
        vm.goToCurrentYear()
        let currentYear = Calendar.current.component(.year, from: .now)
        #expect(vm.year == currentYear)
    }
}

// MARK: - DayDetailViewModel Tests

@Suite("DayDetailViewModel Tests")
@MainActor
struct DayDetailViewModelTests {

    @Test("Initializes with correct date")
    func defaultInit() {
        let date = CalendarDate(date: .now)
        let vm = DayDetailViewModel(calendarDate: date)
        #expect(vm.calendarDate == date)
        #expect(vm.configuration.showFourPillars == true)
    }

    @Test("Initializes with minimal configuration")
    func minimalConfig() {
        let date = CalendarDate(date: .now)
        let vm = DayDetailViewModel(calendarDate: date, configuration: .minimal)
        #expect(vm.configuration.showFourPillars == false)
        #expect(vm.configuration.showTwelveGods == false)
    }

    @Test("update(to:) changes the displayed date")
    func updateDate() {
        let dateA = CalendarDate(
            date: Calendar.current.date(
                from: DateComponents(year: 2026, month: 1, day: 1)
            )!
        )
        let dateB = CalendarDate(
            date: Calendar.current.date(
                from: DateComponents(year: 2026, month: 6, day: 15)
            )!
        )
        let vm = DayDetailViewModel(calendarDate: dateA)
        #expect(vm.calendarDate == dateA)

        vm.update(to: dateB)
        #expect(vm.calendarDate == dateB)
        #expect(vm.calendarDate != dateA)
    }
}

// MARK: - CalendarTheme Tests

@Suite("CalendarTheme Tests")
struct CalendarThemeTests {

    @Test("Default theme has expected default values")
    func defaultTheme() {
        let theme = CalendarTheme.default
        #expect(theme.rowSpacing == 4)
        #expect(theme.columnSpacing == 0)
        #expect(theme.cellPadding == 4)
    }

    @Test("Traditional theme has different spacing")
    func traditionalTheme() {
        let theme = CalendarTheme.traditional
        #expect(theme.rowSpacing == 6)
        #expect(theme.columnSpacing == 2)
        #expect(theme.cellPadding == 6)
    }

    @Test("Custom theme respects all parameters")
    func customTheme() {
        let theme = CalendarTheme(
            rowSpacing: 10,
            columnSpacing: 5,
            cellPadding: 8
        )
        #expect(theme.rowSpacing == 10)
        #expect(theme.columnSpacing == 5)
        #expect(theme.cellPadding == 8)
    }
}

// MARK: - CalendarConfiguration Tests

@Suite("CalendarConfiguration Tests")
struct CalendarConfigurationTests {

    @Test("Default configuration enables all features")
    func defaultConfig() {
        let config = CalendarConfiguration.default
        #expect(config.showLunarDays)
        #expect(config.showSolarTerms)
        #expect(config.showTwelveGods)
        #expect(config.showMoonPhase)
        #expect(config.showFourPillars)
        #expect(config.showLunarMansion)
        #expect(config.showShichen)
    }

    @Test("Minimal configuration only enables lunar days and solar terms")
    func minimalConfig() {
        let config = CalendarConfiguration.minimal
        #expect(config.showLunarDays)
        #expect(config.showSolarTerms)
        #expect(!config.showTwelveGods)
        #expect(!config.showMoonPhase)
        #expect(!config.showFourPillars)
        #expect(!config.showLunarMansion)
        #expect(!config.showShichen)
    }

    @Test("Default first weekday is Sunday (1)")
    func firstWeekday() {
        let config = CalendarConfiguration.default
        #expect(config.firstWeekday == 1)
    }
}
