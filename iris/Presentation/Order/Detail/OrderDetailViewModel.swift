//
//  OrderDetailViewModel.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation
import Observation
import UIKit

/// Order detail: status, payment, delivery hand-off, customer, products and history.
/// Holds the loaded `Order`, exposes display strings, and changes status or deletes through use cases.
@Observable
final class OrderDetailViewModel {
    struct ProductLine: Identifiable, Equatable {
        let id: Int
        let title: String
        let amount: String
    }

    struct HistoryEntry: Identifiable, Equatable {
        let id: Int
        let title: String
        let detail: String
    }

    let shop: Shop

    private(set) var order: Order
    private(set) var isLoading = false
    /// True while a status change or deletion is in flight.
    private(set) var isUpdating = false
    private(set) var errorMessage: String?
    /// Short confirmation shown at the bottom, e.g. after copying. Clears itself.
    private(set) var toastMessage: String?
    /// Settable so the confirmation dialogs can bind to them.
    var isConfirmingCancel = false
    var isConfirmingDelete = false

    private let actor: Email
    private let loadOrder: LoadOrderUseCase
    private let changeStatusUseCase: ChangeOrderStatusUseCase
    private let deleteOrderUseCase: DeleteOrderUseCase
    /// Called after any change so the owner can refresh its lists.
    private let onChanged: () -> Void
    /// Called once the order is gone. The owner pops this screen.
    private let onDeleted: () -> Void
    private let copyToPasteboard: (String) -> Void
    private let calendar: Calendar
    /// Injected clock so "today" and lateness are testable.
    private let now: () -> Date
    private var toastTask: Task<Void, Never>?

    init(
        order: Order,
        shop: Shop,
        actor: Email,
        loadOrder: LoadOrderUseCase,
        changeStatusUseCase: ChangeOrderStatusUseCase,
        deleteOrderUseCase: DeleteOrderUseCase,
        onChanged: @escaping () -> Void,
        onDeleted: @escaping () -> Void,
        copyToPasteboard: @escaping (String) -> Void = { UIPasteboard.general.string = $0 },
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.order = order
        self.shop = shop
        self.actor = actor
        self.loadOrder = loadOrder
        self.changeStatusUseCase = changeStatusUseCase
        self.deleteOrderUseCase = deleteOrderUseCase
        self.onChanged = onChanged
        self.onDeleted = onDeleted
        self.copyToPasteboard = copyToPasteboard
        self.calendar = calendar
        self.now = now
    }

    // MARK: - Header

    /// "Đơn #12"
    var title: String {
        "\(AppStrings.orderNumberPrefix)\(order.number)"
    }

    var statusTitle: String {
        order.status.title
    }

    var isLate: Bool {
        order.isLate(at: now(), calendar: calendar)
    }

    var customerName: String {
        order.details.customerName ?? AppStrings.anonymousCustomer
    }

    /// "Hôm nay · 08:00–10:00 · Giao tận nơi". The time part is omitted when no time was fixed.
    var scheduleLine: String {
        [
            AppFormatters.relativeDay(order.details.deliveryDate, now: now(), calendar: calendar),
            order.details.timeWindow.map(AppFormatters.timeRange),
            order.details.deliveryMethod.title,
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }

    /// Title of the big button that moves the order forward. `nil` once it is finished.
    var primaryActionTitle: String? {
        switch order.status.next {
        case .inProgress?: AppStrings.startMaking
        case .done?: AppStrings.markDelivered
        default: nil
        }
    }

    let statusOptions = OrderStatus.allCases

    // MARK: - Payment

    var isFullyPaid: Bool {
        order.details.pricing.remaining <= 0
    }

    var paymentCaption: String {
        isFullyPaid ? AppStrings.fullyCollected : AppStrings.remainingMoney
    }

    var remainingText: String {
        AppFormatters.money(order.details.pricing.remaining)
    }

    var totalText: String {
        AppFormatters.money(order.details.pricing.total)
    }

    var collectedText: String {
        AppFormatters.money(order.details.pricing.deposit)
    }

    /// Plain-text receipt the shop sends to the customer over chat.
    var invoiceText: String {
        let pricing = order.details.pricing
        var lines = ["\(AppStrings.invoice) \(title) · \(shop.name)", scheduleLine, ""]
        lines += order.details.items.map { "- \($0.name) ×\($0.quantity): \(AppFormatters.money($0.total))" }
        if pricing.shippingFee > 0 {
            lines.append("\(AppStrings.shippingFee): \(AppFormatters.money(pricing.shippingFee))")
        }
        if pricing.discount > 0 {
            lines.append("\(AppStrings.discount): −\(AppFormatters.money(pricing.discount))")
        }
        lines.append("\(AppStrings.orderTotal): \(totalText)")
        if pricing.deposit > 0 {
            lines.append("\(AppStrings.depositPaid): \(collectedText)")
        }
        lines.append("\(AppStrings.remainingAmount): \(remainingText)")
        return lines.joined(separator: "\n")
    }

    // MARK: - Delivery

    /// The address card only applies when the shop delivers.
    var showsDelivery: Bool {
        order.details.deliveryMethod == .delivery
    }

    var recipientName: String {
        order.details.recipient?.name ?? customerName
    }

    var recipientPhone: String? {
        if let recipient = order.details.recipient {
            return recipient.phone
        }
        return order.details.customerPhone
    }

    var callURL: URL? {
        recipientPhone.flatMap { URL(string: "tel:\(Self.digits(of: $0))") }
    }

    var hasAddress: Bool {
        order.details.address != nil
    }

    var addressTitle: String {
        order.details.address ?? AppStrings.noAddress
    }

    var addressSubtitle: String? {
        hasAddress ? nil : AppStrings.tapEditToAdd
    }

    /// Apps in rows of three so the buttons share each line's width.
    var deliveryAppRows: [[DeliveryApp]] {
        let apps = DeliveryApp.allCases
        return stride(from: 0, to: apps.count, by: 3).map { start in
            Array(apps[start..<min(start + 3, apps.count)])
        }
    }

    /// Everything a shipper needs, ready to paste into a delivery app.
    var deliveryInfoText: String {
        var lines = ["\(AppStrings.recipient): \(recipientName)"]
        if let phone = recipientPhone {
            lines.append("\(AppStrings.phoneNumber): \(phone)")
        }
        lines.append("\(AppStrings.address): \(addressTitle)")
        let time = [
            AppFormatters.relativeDay(order.details.deliveryDate, now: now(), calendar: calendar),
            order.details.timeWindow.map(AppFormatters.timeRange),
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
        lines.append("\(AppStrings.deliveryTime): \(time)")
        if let note = order.details.note {
            lines.append("\(AppStrings.note): \(note)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Customer

    /// "0909 123 456 · Zalo"
    var customerLine: String {
        [order.details.customerPhone, order.details.source.title]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    var zaloURL: URL? {
        order.details.customerPhone.flatMap { URL(string: "https://zalo.me/\(Self.digits(of: $0))") }
    }

    // MARK: - Products and notes

    var productLines: [ProductLine] {
        order.details.items.enumerated().map { index, line in
            ProductLine(
                id: index,
                title: line.quantity > 1 ? "\(line.name) ×\(line.quantity)" : line.name,
                amount: AppFormatters.money(line.total)
            )
        }
    }

    var shippingFeeText: String? {
        order.details.pricing.shippingFee > 0 ? AppFormatters.money(order.details.pricing.shippingFee) : nil
    }

    var discountText: String? {
        order.details.pricing.discount > 0 ? "−" + AppFormatters.money(order.details.pricing.discount) : nil
    }

    var cardMessage: String? {
        order.details.cardMessage
    }

    var note: String? {
        order.details.note
    }

    var hasNotes: Bool {
        cardMessage != nil || note != nil
    }

    // MARK: - History

    var historyEntries: [HistoryEntry] {
        order.history.enumerated().map { index, event in
            HistoryEntry(
                id: index,
                title: Self.title(for: event.kind),
                detail: "\(event.actor.value) · \(AppFormatters.clockAndDay(event.date))"
            )
        }
    }

    /// Cancelling only makes sense while the order is still open.
    var canCancel: Bool {
        order.status.isOpen
    }

    // MARK: - Actions

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            order = try await loadOrder.execute(id: order.id)
        } catch let error as OrderError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    /// Moves the order one step forward: new → in progress → done.
    func advanceStatus() async {
        guard let next = order.status.next else { return }
        await changeStatus(to: next)
    }

    func changeStatus(to status: OrderStatus) async {
        guard status != order.status, !isUpdating else { return }
        isUpdating = true
        errorMessage = nil
        defer { isUpdating = false }

        do {
            order = try await changeStatusUseCase.execute(orderId: order.id, to: status, actor: actor)
            onChanged()
        } catch let error as OrderError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func requestCancel() {
        isConfirmingCancel = true
    }

    func confirmCancel() async {
        await changeStatus(to: .cancelled)
    }

    func requestDelete() {
        isConfirmingDelete = true
    }

    func confirmDelete() async {
        guard !isUpdating else { return }
        isUpdating = true
        errorMessage = nil
        defer { isUpdating = false }

        do {
            try await deleteOrderUseCase.execute(id: order.id)
            onDeleted()
        } catch let error as OrderError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func copyDeliveryInfo() {
        copyToPasteboard(deliveryInfoText)
        showToast(AppStrings.copiedDeliveryInfo)
    }

    func edit() {
        // TODO: present the edit form once the order can be edited.
    }

    // MARK: - Private

    private func showToast(_ message: String) {
        toastMessage = message
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self?.toastMessage = nil
        }
    }

    private static func title(for kind: OrderEvent.Kind) -> String {
        switch kind {
        case .created: AppStrings.createdOrder
        case .statusChanged(let status): "\(AppStrings.changedStatusTo) \(status.title)"
        }
    }

    /// Keeps only digits and a leading plus so phone numbers work in URLs.
    private static func digits(of phone: String) -> String {
        phone.filter { $0.isNumber || $0 == "+" }
    }
}
