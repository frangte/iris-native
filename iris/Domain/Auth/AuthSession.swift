//
//  AuthSession.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

/// A successfully authenticated session.
struct AuthSession: Equatable, Hashable {
    let email: Email
    let token: String
}
