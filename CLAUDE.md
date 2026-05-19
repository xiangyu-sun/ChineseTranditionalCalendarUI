# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build
swift build

# Run all tests
swift test

# Run a single test suite
swift test --filter CalendarDateTests
swift test --filter CalendarMonthTests

# Run a single test by name
swift test --filter "CalendarDateTests/gregorianComponents"
```

## Architecture

Swift Package (swift-tools-version 6.0). Depends on [ChineseAstrologyCalendar](https://github.com/xiangyu-sun/ChineseAstrologyCalendar) for all Chinese calendar computations — this package only provides SwiftUI UI layer on top of it.

Platforms: iOS 17+, macOS 14+, watchOS 10+, visionOS 1+. Uses `@Observable` macro (not `ObservableObject`).

### Data flow

`CalendarDate` is the core value type — wraps a `Date`, strips time to midnight, lazily exposes lunar day, solar term (`jieqi`), Four Pillars (`nianZhu/yueZhu/riZhu/shiZhu`), Twelve Gods, moon phase, Lunar Mansion, and Shichen by delegating to `ChineseAstrologyCalendar` extensions.

`CalendarMonth` computes the grid of `CalendarDate?` cells (padded to multiples of 7) for a given year+month.

`CalendarConfiguration` is a `Sendable` struct passed to ViewModels to toggle which data layers render. Two presets: `.default` (all on) and `.minimal` (lunar days + solar terms only).

`CalendarTheme` flows through SwiftUI environment via `.calendarTheme(_:)` modifier. Two presets: `.default` and `.traditional` (red/gold).

### View hierarchy

```
ChineseCalendarView          ← top-level; owns MonthlyCalendarViewModel + YearlyCalendarViewModel
  ├── MonthlyCalendarView    ← 7-column grid, swipe navigation; driven by MonthlyCalendarViewModel
  ├── WeekStripView          ← shares same MonthlyCalendarViewModel as monthly
  ├── YearlyOverviewView     ← driven by YearlyCalendarViewModel; tap navigates to monthly tab
  └── DayDetailView (sheet)  ← full almanac; takes CalendarDate + CalendarConfiguration directly
```

Components (`DayCellView`, `SolarTermBadge`, `FourPillarsView`, `TwelveGodsView`, `MoonPhaseView`, `LunarMansionView`, `JieqiDetailView`, `MonthHeaderView`, `WeekdayHeaderView`) are internal building blocks consumed by the views above.

### Tests

Use Swift Testing (`@Suite`, `@Test`, `#expect`) — not XCTest. Tests live in `Tests/ChineseTranditionalCalendarUITests/`. `ModelTests.swift` covers `CalendarDate` and `CalendarMonth`. `ViewModelTests.swift` covers ViewModel navigation.

### Example app

`Example/ChineseTranditionalCalendarUIExample/` — standalone Xcode project that references the local package. Open the `.xcodeproj` directly.
