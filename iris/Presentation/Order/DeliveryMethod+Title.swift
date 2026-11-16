//
//  DeliveryMethod+Title.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

/// Segment labels for the delivery method picker.
extension DeliveryMethod {
    var title: String {
        switch self {
        case .delivery: AppStrings.deliveryToDoor
        case .pickup: AppStrings.customerPickup
        }
    }
}
