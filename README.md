# ChineseTranditionalCalendarUI

A SwiftUI component library for displaying Chinese traditional calendar data — lunar dates, Four Pillars (四柱八字), solar terms (节气), Twelve Gods (建除十二神), moon phases, Lunar Mansions (二十八宿), and more.

Built on top of [ChineseAstrologyCalendar](https://github.com/xiangyu-sun/ChineseAstrologyCalendar).

## Requirements

- Swift 6.0+
- iOS 17+ / macOS 14+ / watchOS 10+ / visionOS 1+
- Xcode 16+

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/xiangyu-sun/ChineseTranditionalCalendarUI.git",
        branch: "master"
    )
]
```

Then add the product to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["ChineseTranditionalCalendarUI"]
)
```

Or in Xcode: **File > Add Package Dependencies** and enter the repository URL.

## Views

### ChineseCalendarView

Top-level container with segmented Month / Week / Year tabs and a day detail sheet.

```swift
import ChineseTranditionalCalendarUI

ChineseCalendarView()
```

### MonthlyCalendarView

7-column calendar grid with lunar day names, solar term badges, and swipe navigation.

```swift
@State var viewModel = MonthlyCalendarViewModel()

MonthlyCalendarView(viewModel: viewModel)
```

### WeekStripView

Compact horizontal 7-day strip with swipe-to-change-week.

```swift
WeekStripView(viewModel: viewModel)
```

### YearlyOverviewView

12 mini-month grids (3 columns, 2 on watchOS) with tap-to-navigate.

```swift
@State var yearVM = YearlyCalendarViewModel()

ScrollView {
    YearlyOverviewView(viewModel: yearVM)
}
```

### DayDetailView

Full almanac detail for a single date — Four Pillars, Twelve Gods with auspicious/inauspicious activities, solar term health tips & seasonal foods, moon phase, Lunar Mansion, and Shichen.

```swift
DayDetailView(calendarDate: CalendarDate(date: .now))
```

## Configuration

Control which data layers are displayed:

```swift
// Show everything (default)
let config = CalendarConfiguration.default

// Lunar days + solar terms only
let config = CalendarConfiguration.minimal

// Custom
let config = CalendarConfiguration(
    showLunarDays: true,
    showSolarTerms: true,
    showTwelveGods: false,
    showMoonPhase: true,
    showFourPillars: false,
    showLunarMansion: false,
    showShichen: false
)

MonthlyCalendarViewModel(configuration: config)
```

## Theming

Apply a `CalendarTheme` through the SwiftUI environment:

```swift
// Built-in themes
MonthlyCalendarView(viewModel: viewModel)
    .calendarTheme(.default)

MonthlyCalendarView(viewModel: viewModel)
    .calendarTheme(.traditional)  // Red & gold Chinese style

// Custom theme
let custom = CalendarTheme(
    accentColor: .purple,
    weekendColor: .orange,
    solarTermColor: .teal,
    rowSpacing: 8,
    cellPadding: 6
)
MonthlyCalendarView(viewModel: viewModel)
    .calendarTheme(custom)
```

## Example App

An Xcode project demonstrating all components is in `Example/ChineseTranditionalCalendarUIExample/`. Open the `.xcodeproj` — it references the local package automatically.

## Project Structure

```
Sources/ChineseTranditionalCalendarUI/
├── Models/
│   ├── CalendarDate.swift        # Date ↔ Chinese calendar bridge
│   ├── CalendarMonth.swift       # Month grid computation
│   └── CalendarConfiguration.swift
├── ViewModels/
│   ├── MonthlyCalendarViewModel.swift
│   ├── YearlyCalendarViewModel.swift
│   └── DayDetailViewModel.swift
├── Views/
│   ├── ChineseCalendarView.swift # Top-level tabbed container
│   ├── MonthlyCalendarView.swift
│   ├── WeekStripView.swift
│   ├── YearlyOverviewView.swift
│   └── DayDetailView.swift
├── Components/
│   ├── DayCellView.swift
│   ├── MonthHeaderView.swift
│   ├── WeekdayHeaderView.swift
│   ├── SolarTermBadge.swift
│   ├── FourPillarsView.swift
│   ├── TwelveGodsView.swift
│   ├── MoonPhaseView.swift
│   ├── LunarMansionView.swift
│   └── JieqiDetailView.swift
├── Styling/
│   └── CalendarTheme.swift
└── Extensions/
    └── Date+Helpers.swift

Tests/ChineseTranditionalCalendarUITests/
├── ModelTests.swift
└── ViewModelTests.swift
```

## License

MIT License. See [LICENSE](LICENSE) for details.
