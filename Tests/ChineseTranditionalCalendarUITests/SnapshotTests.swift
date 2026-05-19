#if os(iOS)
import Testing
import Foundation
import SwiftUI
import SnapshotTesting
@testable import ChineseTranditionalCalendarUI

// MARK: - Fixtures

private enum Fixture {
    /// Regular weekday — no solar term, not today.
    static let regular = Calendar.current.date(
        from: DateComponents(year: 2026, month: 3, day: 15)
    )!
    /// Spring Equinox 2026 — first day of a new solar term (春分).
    static let solarTerm = Calendar.current.date(
        from: DateComponents(year: 2026, month: 3, day: 20)
    )!
    /// Chinese New Year 2026 — 正月初一.
    static let firstOfLunarMonth = Calendar.current.date(
        from: DateComponents(year: 2026, month: 2, day: 17)
    )!
}

// MARK: - DayCellView

@Suite("DayCellView Snapshots", .snapshots(record: .missing))
struct DayCellViewSnapshots {

    @Test func regularDay() {
        assertSnapshot(
            of: DayCellView(calendarDate: CalendarDate(date: Fixture.regular)),
            as: .image(layout: .fixed(width: 60, height: 60))
        )
    }

    @Test func selectedDay() {
        assertSnapshot(
            of: DayCellView(calendarDate: CalendarDate(date: Fixture.regular), isSelected: true),
            as: .image(layout: .fixed(width: 60, height: 60))
        )
    }

    @Test func solarTermDay() {
        assertSnapshot(
            of: DayCellView(calendarDate: CalendarDate(date: Fixture.solarTerm)),
            as: .image(layout: .fixed(width: 60, height: 60))
        )
    }

    @Test func firstOfLunarMonth() {
        assertSnapshot(
            of: DayCellView(calendarDate: CalendarDate(date: Fixture.firstOfLunarMonth)),
            as: .image(layout: .fixed(width: 60, height: 60))
        )
    }

    @Test func traditionalTheme() {
        assertSnapshot(
            of: DayCellView(calendarDate: CalendarDate(date: Fixture.regular), isSelected: true)
                .calendarTheme(.traditional),
            as: .image(layout: .fixed(width: 60, height: 60))
        )
    }
}

// MARK: - WeekdayHeaderView

@Suite("WeekdayHeaderView Snapshots", .snapshots(record: .missing))
struct WeekdayHeaderViewSnapshots {

    @Test func sundayStart() {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        assertSnapshot(
            of: WeekdayHeaderView(calendar: cal),
            as: .image(layout: .fixed(width: 320, height: 28))
        )
    }

    @Test func mondayStart() {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        assertSnapshot(
            of: WeekdayHeaderView(calendar: cal),
            as: .image(layout: .fixed(width: 320, height: 28))
        )
    }
}

// MARK: - SolarTermBadge

@Suite("SolarTermBadge Snapshots", .snapshots(record: .missing))
struct SolarTermBadgeSnapshots {

    @Test func springEquinox() {
        assertSnapshot(
            of: SolarTermBadge(jieqi: .chunfen).padding(8),
            as: .image
        )
    }

    @Test func winterSolstice_traditionalTheme() {
        assertSnapshot(
            of: SolarTermBadge(jieqi: .dongzhi)
                .padding(8)
                .calendarTheme(.traditional),
            as: .image
        )
    }
}

// MARK: - FourPillarsView

@Suite("FourPillarsView Snapshots", .snapshots(record: .missing))
struct FourPillarsViewSnapshots {

    @Test func defaultTheme() {
        assertSnapshot(
            of: FourPillarsView(calendarDate: CalendarDate(date: Fixture.regular)).padding(),
            as: .image(layout: .fixed(width: 360, height: 120))
        )
    }

    @Test func traditionalTheme() {
        assertSnapshot(
            of: FourPillarsView(calendarDate: CalendarDate(date: Fixture.regular))
                .padding()
                .calendarTheme(.traditional),
            as: .image(layout: .fixed(width: 360, height: 120))
        )
    }
}

// MARK: - MonthlyCalendarView

@Suite("MonthlyCalendarView Snapshots", .snapshots(record: .missing))
struct MonthlyCalendarViewSnapshots {

    @Test func defaultConfig() {
        let vm = MonthlyCalendarViewModel(date: Fixture.regular)
        assertSnapshot(
            of: MonthlyCalendarView(viewModel: vm),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func minimalConfig() {
        let vm = MonthlyCalendarViewModel(date: Fixture.regular, configuration: .minimal)
        assertSnapshot(
            of: MonthlyCalendarView(viewModel: vm),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func mondayStart() {
        let config = CalendarConfiguration(firstWeekday: 2)
        let vm = MonthlyCalendarViewModel(date: Fixture.regular, configuration: config)
        assertSnapshot(
            of: MonthlyCalendarView(viewModel: vm),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func traditionalTheme() {
        let vm = MonthlyCalendarViewModel(date: Fixture.regular)
        assertSnapshot(
            of: MonthlyCalendarView(viewModel: vm).calendarTheme(.traditional),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}

// MARK: - DayDetailView

@Suite("DayDetailView Snapshots", .snapshots(record: .missing))
struct DayDetailViewSnapshots {

    @Test func solarTermDay_defaultConfig() {
        assertSnapshot(
            of: DayDetailView(calendarDate: CalendarDate(date: Fixture.solarTerm)),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func solarTermDay_minimalConfig() {
        assertSnapshot(
            of: DayDetailView(
                calendarDate: CalendarDate(date: Fixture.solarTerm),
                configuration: .minimal
            ),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test func solarTermDay_traditionalTheme() {
        assertSnapshot(
            of: DayDetailView(calendarDate: CalendarDate(date: Fixture.solarTerm))
                .calendarTheme(.traditional),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
#endif
