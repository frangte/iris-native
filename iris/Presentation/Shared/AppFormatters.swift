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

    /// "0", "1.200.000". Grouped digits without a currency suffix, for editable money fields.
    static func number(_ amount: Int) -> String {
        moneyFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }

    /// "0đ", "1.200.000đ".
    static func money(_ amount: Int) -> String {
        number(amount) + "đ"
    }

    /// "08–10h". Hour-only label for a delivery time slot chip.
    static func timeSlot(_ window: DeliveryTimeWindow) -> String {
        String(format: "%02d–%02dh", window.start.hour, window.end.hour)
    }
}
