//
//  TodayViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 13/11/26.
//

import Foundation
import Testing
@testable import iris

@MainActor
struct TodayViewModelTests {
    private struct LoadFailure: Error {}

    private let shop = Shop(id: "shop-1", name: "ABC", phone: nil, address: nil)
    private let repository = MockOrderRepository()
    /// Friday 13 November 2026 at noon, local time.
    private let friday = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 13, hour: 12))!

    private func makeViewModel(onCreateOrder: @escaping () -> Void = {}) -> TodayViewModel {
        TodayViewModel(
            shop: shop,
            loadTodaySummary: LoadTodaySummaryUseCase(repository: repository),
            onCreateOrder: onCreateOrder,
            now: { friday }
        )
    }

    @Test func dateLineShowsVietnameseWeekdayAndShopName() {
        #expect(makeViewModel().dateLine == "Thứ Sáu, 13/11 · ABC")
    }

    @Test func startsWithZeroTilesAndEmptyState() {
        let viewModel = makeViewModel()

        #expect(viewModel.tiles.map(\.value) == ["0", "0", "0đ"])
        #expect(viewModel.tiles.map(\.label) == [AppStrings.ordersToday, AppStrings.late, AppStrings.remainingMoney])
        #expect(viewModel.showsEmptyState)
        #expect(viewModel.isLoading == false)
    }

    @Test func loadFillsTilesFromSummary() async {
        repository.summaryResult = .success(TodaySummary(todayCount: 3, lateCount: 1, remainingAmount: 1_200_000))
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(repository.requestedShopIds == ["shop-1"])
        #expect(viewModel.tiles.map(\.value) == ["3", "1", "1.200.000đ"])
        #expect(viewModel.showsEmptyState == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func loadFailureShowsGenericError() async {
        repository.summaryResult = .failure(LoadFailure())
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.errorMessage == AppStrings.somethingWentWrong)
        #expect(viewModel.showsEmptyState)
    }

    @Test func createOrderFiresCallback() {
        var didRequestCreate = false
        let viewModel = makeViewModel(onCreateOrder: { didRequestCreate = true })

        viewModel.createOrder()

        #expect(didRequestCreate)
    }
}
