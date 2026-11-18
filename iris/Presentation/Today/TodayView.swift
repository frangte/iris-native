//
//  TodayView.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import SwiftUI

/// Home tab: date and shop name, summary tiles, then today's orders or an empty state.
struct TodayView: View {
    @State private var viewModel: TodayViewModel

    init(viewModel: TodayViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.dateLine)
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.secondaryLabel)
                        .padding(.horizontal, DSSpacing.xs)

                    summaryRow
                        .padding(.top, DSSpacing.md)

                    if let errorMessage = viewModel.errorMessage {
                        DSErrorBanner(message: errorMessage)
                            .padding(.top, DSSpacing.md)
                    }

                    if viewModel.showsEmptyState {
                        DSEmptyState(
                            title: AppStrings.noOrder,
                            message: AppStrings.todayOrderDesc,
                            actionTitle: AppStrings.createFirstOrder,
                            actionSystemImage: "plus",
                            action: viewModel.createOrder
                        )
                        .padding(.top, DSSpacing.xxl)
                    }
                    // TODO: render today's, late and upcoming orders when the summary is not empty.
                }
                .padding(.horizontal, DSSpacing.screenPadding)
                .padding(.top, DSSpacing.xxl)
                .padding(.bottom, DSSpacing.xl)
            }
            .background(Color.groupedBackground.ignoresSafeArea())
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.createOrder) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(AppStrings.newOrder)
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .animation(.default, value: viewModel.errorMessage)
            .sheet(isPresented: $viewModel.isCreatingOrder) {
                NewOrderView(viewModel: viewModel.makeNewOrderViewModel())
            }
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(viewModel: viewModel.makeOrderDetailViewModel(for: order))
            }
        }
        .tint(Color.tint)
    }

    // MARK: - Subviews

    private var summaryRow: some View {
        HStack(spacing: DSSpacing.md) {
            ForEach(viewModel.tiles) { tile in
                DSSummaryTile(label: tile.label, value: tile.value)
            }
        }
    }
}

#Preview {
    let container = AppContainer(
        authRepository: InMemoryAuthRepository(),
        shopRepository: InMemoryShopRepository(),
        orderRepository: InMemoryOrderRepository(simulatedDelay: .zero)
    )
    if let actor = Email("abc@abc.com") {
        TodayView(
            viewModel: container.makeTodayViewModel(
                for: Shop(id: "1", name: "ABC", phone: nil, address: nil),
                actor: actor
            )
        )
    }
}
