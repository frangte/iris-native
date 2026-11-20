//
//  ShopMember.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

/// What a member is allowed to do in a shop.
enum ShopRole: Equatable, Hashable {
    /// Created the shop. Can invite members and change shop details.
    case owner
    /// Joined with an invite code. Can view and edit every order, customer and payment.
    case manager
}

/// One person with access to a shop.
struct ShopMember: Equatable, Hashable, Identifiable {
    let email: Email
    let role: ShopRole

    var id: String { email.value }
}
