//
//  Shop.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// A flower shop the signed-in user belongs to.
struct Shop: Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let phone: String?
    let address: String?
}
