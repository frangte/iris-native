//
//  DeliveryTimeWindow.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Wall-clock time without a date, e.g. 09:30.
struct TimeOfDay: Hashable, Comparable {
    let hour: Int
    let minute: Int

    init(hour: Int, minute: Int = 0) {
        self.hour = hour
        self.minute = minute
    }

    var minutesSinceMidnight: Int {
        hour * 60 + minute
    }

    static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool {
        lhs.minutesSinceMidnight < rhs.minutesSinceMidnight
    }
}

/// Time range on the delivery day during which the order should be delivered or picked up.
struct DeliveryTimeWindow: Hashable {
    let start: TimeOfDay
    let end: TimeOfDay

    /// Two-hour slots the shop offers by default, from 08:00 to 20:00.
    static let presets: [DeliveryTimeWindow] = stride(from: 8, to: 20, by: 2).map { hour in
        DeliveryTimeWindow(start: TimeOfDay(hour: hour), end: TimeOfDay(hour: hour + 2))
    }

    /// A window is usable only when it ends after it starts.
    var isValid: Bool {
        end > start
    }
}
