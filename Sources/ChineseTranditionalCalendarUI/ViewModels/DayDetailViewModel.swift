import SwiftUI

/// View model for `DayDetailView`.
@Observable
public final class DayDetailViewModel {

    /// The date being displayed.
    public var calendarDate: CalendarDate

    /// Configuration controlling which sections are visible.
    public var configuration: CalendarConfiguration

    public init(
        calendarDate: CalendarDate,
        configuration: CalendarConfiguration = .default
    ) {
        self.calendarDate = calendarDate
        self.configuration = configuration
    }

    /// Update the displayed date.
    public func update(to date: CalendarDate) {
        calendarDate = date
    }
}
