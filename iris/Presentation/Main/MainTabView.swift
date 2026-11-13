//
//  MainTabView.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import SwiftUI

/// Main app shell shown once the user is inside a shop: four bottom tabs.
struct MainTabView: View {
    /// Bottom tabs in display order.
    enum Tab: Hashable {
        case today
        case orders
        case customers
        case shop
    }

    let container: AppContainer
    let shop: Shop

    @State private var selectedTab: Tab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            SwiftUI.Tab(AppStrings.today, systemImage: "sun.max.fill", value: Tab.today) {
                TodayView(viewModel: container.makeTodayViewModel(for: shop))
            }
            SwiftUI.Tab(AppStrings.order, systemImage: "list.bullet.rectangle", value: Tab.orders) {
                PlaceholderTabView(title: AppStrings.orders)
            }
            SwiftUI.Tab(AppStrings.customer, systemImage: "person.2", value: Tab.customers) {
                PlaceholderTabView(title: AppStrings.customer)
            }
            SwiftUI.Tab(AppStrings.shop, systemImage: "storefront", value: Tab.shop) {
                PlaceholderTabView(title: shop.name)
            }
        }
        .tint(Color.tint)
    }
}

/// Temporary content for tabs that are not built yet.
private struct PlaceholderTabView: View {
    let title: String

    var body: some View {
        NavigationStack {
            Text(AppStrings.comingSoon)
                .font(DSFont.subhead)
                .foregroundStyle(Color.secondaryLabel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.groupedBackground.ignoresSafeArea())
                .navigationTitle(title)
        }
    }
}

#Preview {
    MainTabView(
        container: AppContainer.live(),
        shop: Shop(id: "1", name: "ABC", phone: nil, address: nil)
    )
}
