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

    private func makeViewModel() -> TodayViewModel {
        TodayViewModel(
            shop: shop,
            loadTodaySummary: LoadTodaySummaryUseCase(repository: repository),
            createOrderUseCase: CreateOrderUseCase(repository: repository),
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
        #expect(viewModel.isCreatingOrder == false)
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

    @Test func createOrderPresentsSheet() {
        let viewModel = makeViewModel()

        viewModel.createOrder()

        #expect(viewModel.isCreatingOrder)
    }

    @Test func cancellingNewOrderClosesSheet() {
        let viewModel = makeViewModel()
        viewModel.createOrder()

        viewModel.makeNewOrderViewModel().cancel()

        #expect(viewModel.isCreatingOrder == false)
    }

    @Test func savingNewOrderClosesSheetAndStoresOrderForShop() async {
        let viewModel = makeViewModel()
        viewModel.createOrder()
        let newOrder = viewModel.makeNewOrderViewModel()
        newOrder.input.items[0].name = "Bó hồng"
        newOrder.input.items[0].unitPrice = 200_000

        await newOrder.save()

        #expect(viewModel.isCreatingOrder == false)
        #expect(repository.createdDrafts.count == 1)
        #expect(newOrder.shop == shop)
    }
}
