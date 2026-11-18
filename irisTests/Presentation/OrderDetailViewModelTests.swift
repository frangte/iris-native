//
//  OrderDetailViewModelTests.swift
//  irisTests
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation
import Testing
@testable import iris

@MainActor
struct OrderDetailViewModelTests {
    private let shop = Shop(id: "shop-1", name: "Tiệm hoa Mộc", phone: nil, address: nil)
    private let actor = Email("abc@abc.com")!
    private let repository = MockOrderRepository()
    private let calendar = Calendar.current
    /// Monday 16 November 2026 at 19:35, local time.
    private let evening = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 19, minute: 35))!

    /// A delivery order for today with a morning slot, two roses at 200k each.
    private func makeOrder(
        window: DeliveryTimeWindow? = DeliveryTimeWindow(start: TimeOfDay(hour: 8), end: TimeOfDay(hour: 10)),
        deposit: Int = 0,
        address: String = "",
        status: OrderStatus = .new
    ) throws -> Order {
        var input = OrderInput(deliveryDate: calendar.startOfDay(for: evening))
        input.customerName = "Chị Thảo"
        input.customerPhone = "0909 123 456"
        input.items[0].name = "Bó hồng đỏ"
        input.items[0].quantity = 2
        input.items[0].unitPrice = 200_000
        input.deposit = deposit
        input.address = address
        if let window {
            input.hasTimeWindow = true
            input.startTime = window.start
            input.endTime = window.end
        }
        return Order(
            id: "order-1",
            number: 1,
            shopId: shop.id,
            createdAt: evening,
            details: try OrderDraft(input),
            status: status,
            history: [OrderEvent(kind: .created, actor: actor, date: evening)]
        )
    }

    private func makeViewModel(
        order: Order,
        onChanged: @escaping () -> Void = {},
        onDeleted: @escaping () -> Void = {},
        copyToPasteboard: @escaping (String) -> Void = { _ in }
    ) -> OrderDetailViewModel {
        OrderDetailViewModel(
            order: order,
            shop: shop,
            actor: actor,
            loadOrder: LoadOrderUseCase(repository: repository),
            changeStatusUseCase: ChangeOrderStatusUseCase(repository: repository),
            deleteOrderUseCase: DeleteOrderUseCase(repository: repository),
            onChanged: onChanged,
            onDeleted: onDeleted,
            copyToPasteboard: copyToPasteboard,
            calendar: calendar,
            now: { evening }
        )
    }

    // MARK: - Header

    @Test func headerShowsNumberStatusAndLateSchedule() throws {
        let viewModel = makeViewModel(order: try makeOrder())

        #expect(viewModel.title == "Đơn #1")
        #expect(viewModel.statusTitle == AppStrings.statusNew)
        #expect(viewModel.customerName == "Chị Thảo")
        #expect(viewModel.isLate)
        #expect(viewModel.scheduleLine == "Hôm nay · 08:00–10:00 · Giao tận nơi")
        #expect(viewModel.primaryActionTitle == AppStrings.startMaking)
        #expect(viewModel.canCancel)
    }

    @Test func orderWithoutFixedTimeIsNotLateUntilMidnight() throws {
        let viewModel = makeViewModel(order: try makeOrder(window: nil))

        #expect(viewModel.isLate == false)
        #expect(viewModel.scheduleLine == "Hôm nay · Giao tận nơi")
    }

    @Test func finishedOrderHasNoPrimaryActionAndIsNotLate() throws {
        let viewModel = makeViewModel(order: try makeOrder(status: .done))

        #expect(viewModel.primaryActionTitle == nil)
        #expect(viewModel.isLate == false)
        #expect(viewModel.canCancel == false)
    }

    // MARK: - Payment

    @Test func paymentShowsRemainingUntilDepositCoversTotal() throws {
        let unpaid = makeViewModel(order: try makeOrder())
        #expect(unpaid.isFullyPaid == false)
        #expect(unpaid.paymentCaption == AppStrings.remainingMoney)
        #expect(unpaid.remainingText == "400.000đ")
        #expect(unpaid.totalText == "400.000đ")
        #expect(unpaid.collectedText == "0đ")

        let paid = makeViewModel(order: try makeOrder(deposit: 400_000))
        #expect(paid.isFullyPaid)
        #expect(paid.paymentCaption == AppStrings.fullyCollected)
        #expect(paid.remainingText == "0đ")
    }

    @Test func invoiceListsItemsAndTotals() throws {
        let viewModel = makeViewModel(order: try makeOrder(deposit: 100_000))

        let lines = viewModel.invoiceText.components(separatedBy: "\n")

        #expect(lines.first == "Hoá đơn Đơn #1 · Tiệm hoa Mộc")
        #expect(lines.contains("- Bó hồng đỏ ×2: 400.000đ"))
        #expect(lines.contains("Đã cọc: 100.000đ"))
        #expect(lines.last == "Còn lại: 300.000đ")
    }

    // MARK: - Delivery and customer

    @Test func deliveryFallsBackToCustomerAndFlagsMissingAddress() throws {
        let viewModel = makeViewModel(order: try makeOrder())

        #expect(viewModel.showsDelivery)
        #expect(viewModel.recipientName == "Chị Thảo")
        #expect(viewModel.recipientPhone == "0909 123 456")
        #expect(viewModel.callURL?.absoluteString == "tel:0909123456")
        #expect(viewModel.hasAddress == false)
        #expect(viewModel.addressTitle == AppStrings.noAddress)
        #expect(viewModel.addressSubtitle == AppStrings.tapEditToAdd)
        #expect(viewModel.deliveryAppRows.map(\.count) == [3, 2])
        #expect(viewModel.customerLine == "0909 123 456 · Zalo")
        #expect(viewModel.zaloURL?.absoluteString == "https://zalo.me/0909123456")
    }

    @Test func copyDeliveryInfoWritesPasteboardAndShowsToast() throws {
        var copied: String?
        let viewModel = makeViewModel(order: try makeOrder(address: "12 Nguyễn Huệ"), copyToPasteboard: { copied = $0 })

        viewModel.copyDeliveryInfo()

        #expect(viewModel.addressSubtitle == nil)
        #expect(copied == "Người nhận: Chị Thảo\nĐiện thoại: 0909 123 456\nĐịa chỉ: 12 Nguyễn Huệ\nGiờ giao: Hôm nay · 08:00–10:00")
        #expect(viewModel.toastMessage == AppStrings.copiedDeliveryInfo)
    }

    // MARK: - Products and history

    @Test func productLinesShowQuantityAndTotal() throws {
        let viewModel = makeViewModel(order: try makeOrder())

        #expect(viewModel.productLines.map(\.title) == ["Bó hồng đỏ ×2"])
        #expect(viewModel.productLines.map(\.amount) == ["400.000đ"])
        #expect(viewModel.shippingFeeText == nil)
        #expect(viewModel.hasNotes == false)
    }

    @Test func historyEntryShowsActorAndTime() throws {
        let viewModel = makeViewModel(order: try makeOrder())

        #expect(viewModel.historyEntries.map(\.title) == [AppStrings.createdOrder])
        #expect(viewModel.historyEntries.map(\.detail) == ["abc@abc.com · 19:35 · 16/11"])
    }

    // MARK: - Status changes

    @Test func advanceStatusMovesForwardAndNotifiesOwner() async throws {
        let order = try makeOrder()
        repository.orders = [order]
        var changeCount = 0
        let viewModel = makeViewModel(order: order, onChanged: { changeCount += 1 })

        await viewModel.advanceStatus()

        #expect(viewModel.order.status == .inProgress)
        #expect(viewModel.statusTitle == AppStrings.statusInProgress)
        #expect(viewModel.primaryActionTitle == AppStrings.markDelivered)
        #expect(viewModel.historyEntries.last?.title == "Đổi sang Đang làm")
        #expect(changeCount == 1)

        await viewModel.advanceStatus()

        #expect(viewModel.order.status == .done)
        #expect(viewModel.primaryActionTitle == nil)
        #expect(changeCount == 2)
    }

    @Test func changingToSameStatusDoesNothing() async throws {
        let order = try makeOrder()
        repository.orders = [order]
        var changeCount = 0
        let viewModel = makeViewModel(order: order, onChanged: { changeCount += 1 })

        await viewModel.changeStatus(to: .new)

        #expect(changeCount == 0)
        #expect(viewModel.order.history.count == 1)
    }

    @Test func cancelAsksForConfirmationThenCancels() async throws {
        let order = try makeOrder()
        repository.orders = [order]
        let viewModel = makeViewModel(order: order)

        viewModel.requestCancel()
        #expect(viewModel.isConfirmingCancel)

        await viewModel.confirmCancel()

        #expect(viewModel.order.status == .cancelled)
        #expect(viewModel.canCancel == false)
        #expect(viewModel.isLate == false)
    }

    @Test func deleteRemovesOrderAndNotifiesOwner() async throws {
        let order = try makeOrder()
        repository.orders = [order]
        var didDelete = false
        let viewModel = makeViewModel(order: order, onDeleted: { didDelete = true })

        viewModel.requestDelete()
        #expect(viewModel.isConfirmingDelete)

        await viewModel.confirmDelete()

        #expect(didDelete)
        #expect(repository.deletedIds == ["order-1"])
    }

    @Test func loadOfMissingOrderShowsNotFound() async throws {
        let viewModel = makeViewModel(order: try makeOrder())

        await viewModel.load()

        #expect(viewModel.errorMessage == AppStrings.orderNotFound)
    }

    @Test func loadRefreshesOrderFromRepository() async throws {
        let order = try makeOrder()
        repository.orders = [order]
        _ = try await repository.updateStatus(orderId: order.id, to: .inProgress, by: actor)
        let viewModel = makeViewModel(order: order)

        await viewModel.load()

        #expect(viewModel.order.status == .inProgress)
        #expect(viewModel.errorMessage == nil)
    }
}
