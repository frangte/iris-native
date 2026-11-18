//
//  TodayViewModel.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import Foundation
import Observation

/// Home tab after onboarding: today's date, the shop name, summary tiles and the order list.
/// Also owns the presentation state of the new-order sheet and the pushed order-detail screens.
@Observable
final class TodayViewModel {
    /// One card in the summary row. The view renders these without knowing what each number means.
    struct SummaryTile: Identifiable, Equatable {
        let id: String
        let label: String
        let value: String
    }

    /// Builds the detail view model for a pushed order. The callbacks fire after a change and after deletion.
    typealias OrderDetailFactory = (
        _ order: Order,
        _ onChanged: @escaping () -> Void,
        _ onDeleted: @escaping () -> Void
    ) -> OrderDetailViewModel

    let shop: Shop

    private(set) var summary: TodaySummary = .empty
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    /// True while the new-order sheet is shown. Settable so the sheet can bind to it.
    var isCreatingOrder = false
    /// Orders pushed onto the navigation stack. Settable so the stack can bind to it.
    var path: [Order] = []

    /// Signed-in team member, recorded on every order change.
    private let actor: Email
    private let loadTodaySummary: LoadTodaySummaryUseCase
    private let createOrderUseCase: CreateOrderUseCase
    private let makeOrderDetail: OrderDetailFactory
    /// Injected clock so the date line is testable.
    private let now: () -> Date

    init(
        shop: Shop,
        actor: Email,
        loadTodaySummary: LoadTodaySummaryUseCase,
        createOrderUseCase: CreateOrderUseCase,
        makeOrderDetail: @escaping OrderDetailFactory,
        now: @escaping () -> Date = Date.init
    ) {
        self.shop = shop
        self.actor = actor
        self.loadTodaySummary = loadTodaySummary
        self.createOrderUseCase = createOrderUseCase
        self.makeOrderDetail = makeOrderDetail
        self.now = now
    }

    // MARK: - Display data

    /// "Thứ Sáu, 13/11 · Tiệm hoa Mộc"
    var dateLine: String {
        "\(AppFormatters.dayLine(now())) · \(shop.name)"
    }

    var tiles: [SummaryTile] {
        [
            SummaryTile(id: "today", label: AppStrings.ordersToday, value: String(summary.todayCount)),
            SummaryTile(id: "late", label: AppStrings.late, value: String(summary.lateCount)),
            SummaryTile(id: "remaining", label: AppStrings.remainingMoney, value: AppFormatters.money(summary.remainingAmount)),
        ]
    }

    /// True when the empty state should replace the order list.
    var showsEmptyState: Bool {
        summary.isEmpty
    }

    // MARK: - Actions

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            summary = try await loadTodaySummary.execute(shopId: shop.id)
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func createOrder() {
        isCreatingOrder = true
    }

    /// Builds the view model for the new-order sheet.
    /// Saving closes the sheet, opens the new order's detail and reloads the summary.
    func makeNewOrderViewModel() -> NewOrderViewModel {
        NewOrderViewModel(
            shop: shop,
            actor: actor,
            createOrderUseCase: createOrderUseCase,
            onSaved: { [weak self] order in
                self?.isCreatingOrder = false
                self?.path.append(order)
                Task { await self?.load() }
            },
            onCancel: { [weak self] in
                self?.isCreatingOrder = false
            },
            now: now
        )
    }

    /// Builds the view model for a pushed order. Changes reload the summary; deletion pops back here.
    func makeOrderDetailViewModel(for order: Order) -> OrderDetailViewModel {
        makeOrderDetail(
            order,
            { [weak self] in
                Task { await self?.load() }
            },
            { [weak self] in
                self?.path.removeAll()
                Task { await self?.load() }
            }
        )
    }
}
