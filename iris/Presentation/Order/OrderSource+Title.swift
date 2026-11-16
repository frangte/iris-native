//
//  OrderSource+Title.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Chip labels for the order source picker.
extension OrderSource {
    var title: String {
        switch self {
        case .zalo: AppStrings.sourceZalo
        case .messenger: AppStrings.sourceMessenger
        case .tiktok: AppStrings.sourceTikTok
        case .instagram: AppStrings.sourceInstagram
        case .phoneCall: AppStrings.sourcePhoneCall
        case .walkIn: AppStrings.sourceWalkIn
        case .other: AppStrings.sourceOther
        }
    }
}
