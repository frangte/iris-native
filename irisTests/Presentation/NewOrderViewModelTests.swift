//
//  NewOrderViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation
import Testing
@testable import iris

@MainActor
struct NewOrderViewModelTests {
    private struct SaveFailure: Error {}

    private let shop = Shop(id: "shop-1", name: "ABC", phone: nil, address: nil)
    private let repository = MockOrderRepository()
    private let calendar = Calendar.current
    /// Monday 16 November 2026 at 15:00, local time.
    private let monday = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 15))!

    private func makeViewModel(
        onSaved: @escaping (Order) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) -> NewOrderViewModel {
        NewOrderViewModel(
            shop: shop,
            createOrderUseCase: CreateOrderUseCase(repository: repository),
            onSaved: onSaved,
            onCancel: onCancel,
            calendar: calendar,
            now: { monday }
        )
    }

    /// Fills the first line so the order becomes valid.
    private func addValidItem(to viewModel: NewOrderViewModel, price: Int = 200_000) {
        viewModel.input.items[0].name = "Bó hồng đỏ"
        viewModel.input.items[0].unitPrice = price
    }

    // MARK: - Initial state

    @Test func startsEmptyWithTodayAndNoFixedTime() {
        let viewModel = makeViewModel()

        #expect(viewModel.input.items.count == 1)
        #expect(viewModel.isTodaySelected)
        #expect(viewModel.isTomorrowSelected == false)
        #expect(viewModel.timeSlotOptions.last?.isSelected == true)
        #expect(viewModel.timeSlotOptions.filter(\.isSelected).count == 1)
        #expect(viewModel.saveButtonTitle == "Lưu đơn · 0đ")
        #expect(viewModel.validationHint == AppStrings.addAtLeastOne)
        #expect(viewModel.canSave == false)
        #expect(viewModel.canRemoveItems == false)
        #expect(viewModel.showsDeliveryAddress)
    }

    @Test func timeSlotTitlesUseHourRanges() {
        let titles = makeViewModel().timeSlotOptions.map(\.title)

        #expect(titles == ["08–10h", "10–12h", "12–14h", "14–16h", "16–18h", "18–20h", AppStrings.noFixedTime])
    }

    // MARK: - Pricing

    @Test func totalsFollowItemsShippingDiscountAndDeposit() {
        let viewModel = makeViewModel()
        addValidItem(to: viewModel, price: 300_000)
        viewModel.input.items[0].quantity = 2
        viewModel.input.shippingFee = 30_000
        viewModel.input.discount = 50_000
        viewModel.input.deposit = 100_000

        #expect(viewModel.totalText == "580.000đ")
        #expect(viewModel.remainingText == "480.000đ")
        #expect(viewModel.saveButtonTitle == "Lưu đơn · 580.000đ")
        #expect(viewModel.canSave)
        #expect(viewModel.validationHint == nil)
    }

    @Test func depositAboveTotalBlocksSave() {
        let viewModel = makeViewModel()
        addValidItem(to: viewModel, price: 100_000)
        viewModel.input.deposit = 150_000

        #expect(viewModel.validationHint == AppStrings.depositExceedTheOrderTotal)
        #expect(viewModel.canSave == false)
    }

    // MARK: - Delivery schedule

    @Test func selectingTomorrowMovesDeliveryDate() {
        let viewModel = makeViewModel()

        viewModel.selectTomorrow()

        #expect(viewModel.isTomorrowSelected)
        #expect(viewModel.isTodaySelected == false)
        #expect(calendar.component(.day, from: viewModel.input.deliveryDate) == 17)

        viewModel.selectToday()

        #expect(viewModel.isTodaySelected)
    }

    @Test func selectingPresetSlotSetsStartAndEnd() {
        let viewModel = makeViewModel()
        let slot = viewModel.timeSlotOptions[2]

        viewModel.select(slot)

        #expect(viewModel.input.hasTimeWindow)
        #expect(viewModel.input.startTime == TimeOfDay(hour: 12))
        #expect(viewModel.input.endTime == TimeOfDay(hour: 14))
        #expect(viewModel.timeSlotOptions[2].isSelected)
        #expect(viewModel.timeSlotOptions.last?.isSelected == false)
    }

    @Test func selectingNoFixedTimeClearsWindow() {
        let viewModel = makeViewModel()
        viewModel.select(viewModel.timeSlotOptions[0])

        viewModel.select(viewModel.timeSlotOptions.last!)

        #expect(viewModel.input.hasTimeWindow == false)
        #expect(viewModel.timeSlotOptions.last?.isSelected == true)
    }

    @Test func customTimeSelectsNoPreset() {
        let viewModel = makeViewModel()
        viewModel.select(viewModel.timeSlotOptions[0])

        viewModel.endTimeDate = calendar.date(bySettingHour: 11, minute: 30, second: 0, of: monday)!

        #expect(viewModel.input.endTime == TimeOfDay(hour: 11, minute: 30))
        #expect(viewModel.timeSlotOptions.allSatisfy { $0.isSelected == false })
    }

    @Test func endBeforeStartBlocksSave() {
        let viewModel = makeViewModel()
        addValidItem(to: viewModel)
        viewModel.select(viewModel.timeSlotOptions[0])
        viewModel.input.endTime = TimeOfDay(hour: 7)

        #expect(viewModel.validationHint == AppStrings.endTimeMustAfterStartTime)
    }

    @Test func pickupHidesAddressSection() {
        let viewModel = makeViewModel()

        viewModel.input.deliveryMethod = .pickup

        #expect(viewModel.showsDeliveryAddress == false)
    }

    // MARK: - Items and recipient

    @Test func addAndRemoveItems() {
        let viewModel = makeViewModel()

        viewModel.addItem()
        #expect(viewModel.input.items.count == 2)
        #expect(viewModel.canRemoveItems)

        viewModel.removeItem(id: viewModel.input.items[0].id)
        #expect(viewModel.input.items.count == 1)

        // The last line can never be removed.
        viewModel.removeItem(id: viewModel.input.items[0].id)
        #expect(viewModel.input.items.count == 1)
    }

    @Test func toggleRecipientSwitchesLabelsAndClearsFields() {
        let viewModel = makeViewModel()
        #expect(viewModel.recipientLine == AppStrings.recipientIsCustomer)
        #expect(viewModel.recipientToggleTitle == AppStrings.change)

        viewModel.toggleSeparateRecipient()
        viewModel.input.recipientName = "Anh Nam"
        #expect(viewModel.recipientLine == AppStrings.recipient)
        #expect(viewModel.recipientToggleTitle == AppStrings.sameAsCustomer)

        viewModel.toggleSeparateRecipient()
        #expect(viewModel.input.hasSeparateRecipient == false)
        #expect(viewModel.input.recipientName == "")
    }

    // MARK: - Save

    @Test func saveStoresDraftAndReportsOrder() async {
        var savedOrder: Order?
        let viewModel = makeViewModel(onSaved: { savedOrder = $0 })
        addValidItem(to: viewModel)
        viewModel.input.customerName = "  Chị Thảo "
        viewModel.input.source = .messenger

        await viewModel.save()

        #expect(repository.createdDrafts.count == 1)
        #expect(repository.createdDrafts.first?.customerName == "Chị Thảo")
        #expect(repository.createdDrafts.first?.source == .messenger)
        #expect(savedOrder?.shopId == "shop-1")
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isSaving == false)
    }

    @Test func saveWithInvalidFormShowsHintAsError() async {
        let viewModel = makeViewModel()

        await viewModel.save()

        #expect(repository.createdDrafts.isEmpty)
        #expect(viewModel.errorMessage == AppStrings.addAtLeastOne)
    }

    @Test func saveFailureShowsGenericError() async {
        repository.createError = SaveFailure()
        let viewModel = makeViewModel()
        addValidItem(to: viewModel)

        await viewModel.save()

        #expect(viewModel.errorMessage == AppStrings.somethingWentWrong)
    }

    @Test func editingClearsError() async {
        let viewModel = makeViewModel()
        await viewModel.save()
        #expect(viewModel.errorMessage != nil)

        viewModel.input.customerName = "A"

        #expect(viewModel.errorMessage == nil)
    }

    @Test func cancelFiresCallback() {
        var didCancel = false
        let viewModel = makeViewModel(onCancel: { didCancel = true })

        viewModel.cancel()

        #expect(didCancel)
    }
}
