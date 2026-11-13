//
//  TodayViewModel.swift
//  iris
//
//  Created by SonnyHoang on 13/11/26.
//

import Foundation
import Observation

/// Home tab after onboarding: today's date, the shop name, summary tiles and the order list.
@Observable
final class TodayViewModel {
    /// One card in the summary row. The view renders these without knowing what each number means.
    struct SummaryTile: Identifiable, Equatable {
        let id: String
        let label: String
        let value: String
    }

    let shop: Shop

    private(set) var summary: TodaySummary = .empty
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let loadTodaySummary: LoadTodaySummaryUseCase
    /// Called when the user asks to create an order. The owner decides how to present the form.
    private let onCreateOrder: () -> Void
    /// Injected clock so the date line is testable.
    private let now: () -> Date

    init(
        shop: Shop,
        loadTodaySummary: LoadTodaySummaryUseCase,
        onCreateOrder: @escaping () -> Void,
        now: @escaping () -> Date = Date.init
    ) {
        self.shop = shop
        self.loadTodaySummary = loadTodaySummary
        self.onCreateOrder = onCreateOrder
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
        onCreateOrder()
    }
}
