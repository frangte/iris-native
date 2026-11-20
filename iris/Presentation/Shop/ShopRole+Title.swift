//
//  ShopRole+Title.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

/// Display text for member roles. Lives in Presentation so Domain stays free of UI strings.
extension ShopRole {
    var title: String {
        switch self {
        case .owner: AppStrings.owner
        case .manager: AppStrings.manager
        }
    }
}
