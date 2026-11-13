//
//  RootView.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI
import SwiftData

/// Picks the root screen from the app session state: login, onboarding, or the main app.
struct RootView: View {
    let container: AppContainer

    var body: some View {
        let sessionStore = container.sessionStore

        if let session = sessionStore.session {
            if let shop = sessionStore.shop {
                MainTabView(container: container, shop: shop)
            } else {
                OnboardingView(viewModel: container.makeOnboardingViewModel(for: session))
            }
        } else {
            AuthView(viewModel: container.makeAuthViewModel())
        }
    }
}

#Preview {
    RootView(container: AppContainer.live())
        .modelContainer(for: Item.self, inMemory: true)
}
