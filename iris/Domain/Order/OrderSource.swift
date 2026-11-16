//
//  OrderSource.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Channel the customer used to place the order. Display titles live in Presentation.
enum OrderSource: String, CaseIterable, Hashable {
    case zalo
    case messenger
    case tiktok
    case instagram
    case phoneCall
    case walkIn
    case other
}
