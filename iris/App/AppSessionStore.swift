//
//  AppSessionStore.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import Observation

/// App-wide sign-in state. `RootView` observes it to pick the root screen.
/// Feature view models never read it directly; they report results through callbacks.
@Observable
final class AppSessionStore {
    private(set) var session: AuthSession?
    /// Shop the user is working in. `nil` until onboarding completes.
    private(set) var shop: Shop?
    /// Name the user typed in the Shop tab. Empty until they set one.
    private(set) var displayName = ""

    func signIn(_ session: AuthSession) {
        self.session = session
    }

    func enter(_ shop: Shop) {
        self.shop = shop
    }

    func updateDisplayName(_ name: String) {
        displayName = name
    }

    func signOut() {
        shop = nil
        session = nil
        displayName = ""
    }
}
