//
//  OrderStatus+Title.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Labels and pill colors for order statuses.
extension OrderStatus {
    var title: String {
        switch self {
        case .new: AppStrings.statusNew
        case .inProgress: AppStrings.statusInProgress
        case .done: AppStrings.delivered
        case .cancelled: AppStrings.cancelled
        }
    }

    var pillStyle: DSStatusPill.Style {
        switch self {
        case .new, .inProgress: .tint
        case .done: .success
        case .cancelled: .neutral
        }
    }
}
