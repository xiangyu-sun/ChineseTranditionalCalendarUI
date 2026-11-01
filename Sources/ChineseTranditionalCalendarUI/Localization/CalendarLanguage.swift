import SwiftUI
import ChineseAstrologyCalendar

// MARK: - Environment

extension EnvironmentValues {

    /// The language the calendar views render library names and UI strings in.
    ///
    /// Defaults to `.zhHant`, which reproduces the package's original output.
    /// Set it with `.environment(\.calendarLanguage, .zhHans)`.
    @Entry public var calendarLanguage: DisplayLanguage = .zhHant
}

// MARK: - UI strings

extension DisplayLanguage {

    /// The UI string for `key` in this language, from the package's string table.
    ///
    /// Languages the table does not carry (`ru`, `es`) fall back to English.
    /// `args` fill the key's positional specifiers (`%1$@`, `%2$@`).
    func string(_ key: String, _ args: CVarArg...) -> String {
        let format = Self.tableBundle(for: self).localizedString(forKey: key, value: key, table: nil)
        guard !args.isEmpty else { return format }
        return String(format: format, locale: Locale(identifier: identifier), arguments: args)
    }

    private static func tableBundle(for language: DisplayLanguage) -> Bundle {
        let name: String
        switch language {
        case .zhHant: name = "zh-Hant"
        case .zhHans: name = "zh-Hans"
        default: name = "en"
        }
        guard let path = Bundle.module.path(forResource: name, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { return Bundle.module }
        return bundle
    }

    /// Long-form almanac prose that exists in Traditional Chinese only.
    ///
    /// Simplified Chinese gets an ICU conversion; every other language shows
    /// the Traditional text unchanged.
    func prose(_ traditional: String) -> String {
        guard self == .zhHans else { return traditional }
        return traditional.applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? traditional
    }
}

// MARK: - Language-aware date text

extension CalendarDate {

    /// Name of the lunar day in `language` ("初一", or "1st" in English).
    public func lunarDayName(in language: DisplayLanguage) -> String {
        lunarDay?.localizedName(in: language) ?? ""
    }

    /// Name of the lunar month in `language` ("正月", "闰四月", "Leap 4th Month").
    public func lunarMonthName(in language: DisplayLanguage) -> String {
        lunarMonth?.localizedName(in: language) ?? lunarDayName(in: language)
    }

    /// Full lunar date such as "甲辰年三月初一" in `language`.
    public func chineseYearMonthDate(in language: DisplayLanguage) -> String {
        lunarDate?.formatted(.yearMonthDay, in: language) ?? ""
    }

    /// Name of the solar term starting on this date in `language`, or nil.
    public func jieqiName(in language: DisplayLanguage) -> String? {
        jieqi?.localizedName(in: language)
    }

    /// The year pillar with its 年 suffix ("甲辰年"), or "Jiǎchén year" in English.
    func yearPillarText(in language: DisplayLanguage) -> String? {
        nianZhu.map { language.string("%1$@年", $0.localizedName(in: language)) }
    }

    /// Lunar month name on 初一, else the lunar day name.
    func lunarDisplayText(in language: DisplayLanguage) -> String {
        isFirstOfLunarMonth ? lunarMonthName(in: language) : lunarDayName(in: language)
    }
}
