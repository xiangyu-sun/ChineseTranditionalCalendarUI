import Testing
import Foundation
import SwiftUI
import ChineseAstrologyCalendar
@testable import ChineseTranditionalCalendarUI

@Suite("Calendar language")
struct CalendarLanguageTests {

    private let china = TimeZone(secondsFromGMT: 8 * 3600)!

    /// 2023-03-22 is 閏二月初一 of 癸卯年.
    private var leapMonthDay: CalendarDate {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = china
        let date = calendar.date(from: DateComponents(year: 2023, month: 3, day: 22, hour: 12))!
        return CalendarDate(date: date, calendar: calendar)
    }

    @Test("calendarLanguage defaults to Traditional Chinese")
    func defaultsToZhHant() {
        #expect(EnvironmentValues().calendarLanguage == .zhHant)
    }

    @Test("Traditional Chinese output is unchanged")
    func zhHantUnchanged() {
        let day = leapMonthDay
        #expect(day.lunarMonthName == "閏二月")
        #expect(day.lunarMonthName(in: .zhHant) == "閏二月")
        #expect(day.chineseYearMonthDate == "癸卯年閏二月初一")
        #expect(day.chineseYearMonthDate(in: .zhHant) == day.chineseYearMonthDate)
        #expect(day.lunarDayName == "初一")
        #expect(day.lunarDayName(in: .zhHant) == "初一")
    }

    @Test("Simplified Chinese and English differ from Traditional")
    func otherLanguages() {
        let day = leapMonthDay
        #expect(day.lunarMonthName(in: .zhHans) == "闰二月")
        #expect(day.lunarMonthName(in: .en) == "Leap 2nd Month")
        #expect(day.chineseYearMonthDate(in: .zhHans) == "癸卯年闰二月初一")
        for language in [DisplayLanguage.zhHans, .en] {
            #expect(!day.lunarMonthName(in: language).isEmpty)
            #expect(day.lunarMonthName(in: language) != day.lunarMonthName)
            #expect(!day.chineseYearMonthDate(in: language).isEmpty)
            #expect(day.chineseYearMonthDate(in: language) != day.chineseYearMonthDate)
        }
        #expect(day.lunarDayName(in: .en) == "1st")
    }

    @Test("Solar term names follow the language")
    func jieqiNames() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = china
        let date = calendar.date(from: DateComponents(year: 2025, month: 4, day: 4, hour: 12))!
        let day = CalendarDate(date: date, calendar: calendar)
        #expect(day.jieqiName == "清明")
        #expect(day.jieqiName(in: .zhHant) == "清明")
        #expect(day.jieqiName(in: .zhHans) == "清明")
        #expect(day.jieqiName(in: .en) == "Qingming")
    }

    @Test("Day labels carry the requested language")
    func dayLabelLanguage() {
        let day = leapMonthDay
        let config = CalendarConfiguration.default
        #expect(day.dayLabel(configuration: config)?.text == day.dayLabel(configuration: config, language: .zhHant)?.text)
        #expect(day.dayLabel(configuration: config, language: .zhHans)?.text == "闰二月")
        #expect(day.dayLabel(configuration: config, language: .en)?.text == "Leap 2nd Month")
    }

    @Test("Prose converts to Simplified only for zh-Hans")
    func prose() {
        #expect(DisplayLanguage.zhHant.prose("萬事開關") == "萬事開關")
        #expect(DisplayLanguage.en.prose("萬事開關") == "萬事開關")
        #expect(DisplayLanguage.zhHans.prose("萬事開關") == "万事开关")
    }
}

@Suite("String table")
struct StringTableTests {

    private struct Catalog: Decodable {
        struct Entry: Decodable {
            struct Localization: Decodable {
                struct Unit: Decodable { let state: String; let value: String }
                let stringUnit: Unit
            }
            let localizations: [String: Localization]
        }
        let sourceLanguage: String
        let strings: [String: Entry]
    }

    private func loadCatalog() throws -> Catalog {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/ChineseTranditionalCalendarUI/Resources/Localizable.xcstrings")
        return try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url))
    }

    private func placeholders(_ text: String) -> [String] {
        text.matches(of: /%\d\$@/).map { String($0.output) }.sorted()
    }

    @Test("Every key has zh-Hant, zh-Hans and en values with matching placeholders")
    func catalogIsComplete() throws {
        let catalog = try loadCatalog()
        #expect(catalog.sourceLanguage == "en")
        #expect(!catalog.strings.isEmpty)
        for (key, entry) in catalog.strings {
            for locale in ["zh-Hant", "zh-Hans", "en"] {
                let unit = try #require(entry.localizations[locale], "\(key) lacks \(locale)").stringUnit
                #expect(unit.state == "translated", "\(key) \(locale)")
                #expect(!unit.value.isEmpty, "\(key) \(locale)")
                #expect(placeholders(unit.value) == placeholders(key), "\(key) \(locale)")
            }
        }
    }

    @Test("The bundled table resolves each key per language")
    func bundledLookups() throws {
        let catalog = try loadCatalog()
        for (key, entry) in catalog.strings {
            for (locale, language) in [("zh-Hant", DisplayLanguage.zhHant), ("zh-Hans", .zhHans), ("en", .en)] {
                let expected = try #require(entry.localizations[locale]).stringUnit.value
                let filled = expected.replacing(/%\d\$@/, with: "X")
                #expect(language.string(key, "X", "X", "X", "X") == filled, "\(key) \(locale)")
            }
        }
    }

    @Test("Traditional Chinese keeps the key text")
    func zhHantMatchesKey() throws {
        let catalog = try loadCatalog()
        for (key, entry) in catalog.strings where key.unicodeScalars.contains(where: { $0.value > 0x2E80 }) {
            #expect(entry.localizations["zh-Hant"]?.stringUnit.value == key)
        }
    }
}
