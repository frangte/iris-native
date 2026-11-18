//
//  DeliveryApp.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation

/// Shipping apps the shop hands deliveries to. Tapping one copies the delivery info, then opens the app.
enum DeliveryApp: String, CaseIterable, Identifiable {
    case grab
    case xanhSM
    case be
    case ahamove
    case lalamove

    var id: String { rawValue }

    /// Brand name, not localized.
    var title: String {
        switch self {
        case .grab: "Grab"
        case .xanhSM: "Xanh SM"
        case .be: "Be"
        case .ahamove: "Ahamove"
        case .lalamove: "Lalamove"
        }
    }

    /// Deep link that opens the installed app.
    var appURL: URL? {
        let scheme = switch self {
        case .grab: "grab"
        case .xanhSM: "xanhsm"
        case .be: "be"
        case .ahamove: "ahamove"
        case .lalamove: "lalamove"
        }
        return URL(string: "\(scheme)://")
    }

    /// App Store search for the app, used when it is not installed.
    var storeURL: URL? {
        var components = URLComponents(string: "itms-apps://search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search")
        components?.queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "term", value: title),
        ]
        return components?.url
    }
}
