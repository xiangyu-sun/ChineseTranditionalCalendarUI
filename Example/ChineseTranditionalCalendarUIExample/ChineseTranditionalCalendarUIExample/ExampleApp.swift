import SwiftUI
import ChineseTranditionalCalendarUI

@main
struct ChineseTranditionalCalendarUIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Content View

struct ContentView: View {

    @State private var selectedDemo: DemoSection? = .fullCalendar
    @State private var useTraditionalTheme = false

    var body: some View {
        NavigationStack {
            List(DemoSection.allCases) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.icon)
                }
            }
            .navigationTitle("Examples")
            .navigationDestination(for: DemoSection.self) { section in
                section.destination
                    .calendarTheme(useTraditionalTheme ? .traditional : .default)
                    .navigationTitle(section.title)
                    #if os(iOS) || os(visionOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button {
                                withAnimation { useTraditionalTheme.toggle() }
                            } label: {
                                Image(systemName: useTraditionalTheme ? "paintpalette.fill" : "paintpalette")
                            }
                            .help("Toggle traditional red theme")
                        }
                    }
            }
        }
    }
}

// MARK: - Demo Sections

enum DemoSection: String, CaseIterable, Identifiable, Hashable {
    case fullCalendar
    case monthlyGrid
    case weekStrip
    case dayDetail
    case yearOverview
    case theming

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fullCalendar: "Full Calendar"
        case .monthlyGrid: "Monthly Grid"
        case .weekStrip: "Week Strip"
        case .dayDetail: "Day Detail"
        case .yearOverview: "Year Overview"
        case .theming: "Theme Presets"
        }
    }

    var icon: String {
        switch self {
        case .fullCalendar: "calendar"
        case .monthlyGrid: "square.grid.3x3"
        case .weekStrip: "calendar.day.timeline.left"
        case .dayDetail: "doc.text.magnifyingglass"
        case .yearOverview: "calendar.badge.clock"
        case .theming: "paintpalette"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .fullCalendar:
            FullCalendarDemo()
        case .monthlyGrid:
            MonthlyGridDemo()
        case .weekStrip:
            WeekStripDemo()
        case .dayDetail:
            DayDetailDemo()
        case .yearOverview:
            YearOverviewDemo()
        case .theming:
            ThemingDemo()
        }
    }
}

// MARK: - Full Calendar Demo

struct FullCalendarDemo: View {
    var body: some View {
        ChineseCalendarView()
    }
}

// MARK: - Monthly Grid Demo

struct MonthlyGridDemo: View {
    @State private var viewModel = MonthlyCalendarViewModel()

    var body: some View {
        VStack {
            MonthlyCalendarView(viewModel: viewModel)

            if let selected = viewModel.selectedDate {
                Divider()
                Text(selected.chineseYearMonthDate)
                    .font(.headline)
                    .padding()
            }

            Spacer()
        }
    }
}

// MARK: - Week Strip Demo

struct WeekStripDemo: View {
    @State private var viewModel = MonthlyCalendarViewModel()

    var body: some View {
        VStack {
            WeekStripView(viewModel: viewModel)

            if let selected = viewModel.selectedDate {
                Divider()
                DayDetailView(calendarDate: selected)
            } else {
                Spacer()
                Text("Tap a day in the strip")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
}

// MARK: - Day Detail Demo

struct DayDetailDemo: View {
    var body: some View {
        DayDetailView(calendarDate: CalendarDate(date: .now))
    }
}

// MARK: - Year Overview Demo

struct YearOverviewDemo: View {
    @State private var viewModel = YearlyCalendarViewModel()

    var body: some View {
        ScrollView {
            YearlyOverviewView(viewModel: viewModel)
        }
    }
}

// MARK: - Theming Demo

struct ThemingDemo: View {
    @State private var viewModel = MonthlyCalendarViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GroupBox("Default Theme") {
                    MonthlyCalendarView(viewModel: viewModel)
                        .calendarTheme(.default)
                }

                GroupBox("Traditional Red Theme") {
                    MonthlyCalendarView(viewModel: viewModel)
                        .calendarTheme(.traditional)
                }

                GroupBox("Minimal Config (lunar + solar terms only)") {
                    MonthlyCalendarView(
                        viewModel: MonthlyCalendarViewModel(
                            configuration: .minimal
                        )
                    )
                    .calendarTheme(.default)
                }
            }
            .padding()
        }
    }
}


