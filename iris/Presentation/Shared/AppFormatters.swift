//
//  AppFormatters.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import Foundation

/// Display formatting shared by the Presentation layer. All output follows Vietnamese conventions.
enum AppFormatters {
    private static let vietnamese = Locale(identifier: "vi_VN")

    /// "Thứ Sáu, 13/11". Weekday name plus day/month, no year.
    private static let dayLineFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = vietnamese
        formatter.dateFormat = "EEEE, dd/MM"
        return formatter
    }()

    /// Whole VND amounts with a dot as the thousands separator: 1.200.000.
    private static let moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = vietnamese
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func dayLine(_ date: Date) -> String {
        let line = dayLineFormatter.string(from: date)
        // Weekday names come back lowercase in some locale data; the design shows them capitalized.
        return line.prefix(1).uppercased() + line.dropFirst()
    }

    /// "0đ", "1.200.000đ".
    static func money(_ amount: Int) -> String {
        let number = moneyFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
        return number + "đ"
    }
}
