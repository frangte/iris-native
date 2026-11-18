//
//  NewOrderViewModel.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation
import Observation

/// New-order form: customer, products, delivery schedule, recipient, notes and payment.
/// Holds the raw `OrderInput`, exposes derived display data, and saves through the use case.
@Observable
final class NewOrderViewModel {
    /// One time-slot chip. `window` is `nil` for "no fixed time".
    struct TimeSlotOption: Identifiable, Equatable {
        let id: String
        let title: String
        let window: DeliveryTimeWindow?
        let isSelected: Bool
    }

    let shop: Shop

    /// Everything the user has typed. Any edit clears the last error.
    var input: OrderInput {
        didSet { errorMessage = nil }
    }
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    /// Team member creating the order, recorded in its history.
    private let actor: Email
    private let createOrderUseCase: CreateOrderUseCase
    /// Called with the stored order. The owner dismisses the form and refreshes its list.
    private let onSaved: (Order) -> Void
    private let onCancel: () -> Void
    private let calendar: Calendar
    /// Injected clock so "today" and "tomorrow" are testable.
    private let now: () -> Date

    init(
        shop: Shop,
        actor: Email,
        createOrderUseCase: CreateOrderUseCase,
        onSaved: @escaping (Order) -> Void,
        onCancel: @escaping () -> Void,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.shop = shop
        self.actor = actor
        self.createOrderUseCase = createOrderUseCase
        self.onSaved = onSaved
        self.onCancel = onCancel
        self.calendar = calendar
        self.now = now
        self.input = OrderInput(deliveryDate: calendar.startOfDay(for: now()))
    }

    // MARK: - Display data

    let sourceOptions = OrderSource.allCases
    let deliveryMethodOptions = DeliveryMethod.allCases

    var isTodaySelected: Bool {
        calendar.isDate(input.deliveryDate, inSameDayAs: now())
    }

    var isTomorrowSelected: Bool {
        calendar.isDate(input.deliveryDate, inSameDayAs: tomorrow)
    }

    /// Preset two-hour slots followed by "no fixed time". A custom start/end selects no preset.
    var timeSlotOptions: [TimeSlotOption] {
        let presets = DeliveryTimeWindow.presets.map { window in
            TimeSlotOption(
                id: "\(window.start.hour)-\(window.end.hour)",
                title: AppFormatters.timeSlot(window),
                window: window,
                isSelected: input.hasTimeWindow && input.startTime == window.start && input.endTime == window.end
            )
        }
        let none = TimeSlotOption(id: "none", title: AppStrings.noFixedTime, window: nil, isSelected: !input.hasTimeWindow)
        return presets + [none]
    }

    /// Start time as a `Date` on the delivery day, for `DatePicker`.
    var startTimeDate: Date {
        get { date(at: input.startTime) }
        set { input.startTime = timeOfDay(from: newValue) }
    }

    /// End time as a `Date` on the delivery day, for `DatePicker`.
    var endTimeDate: Date {
        get { date(at: input.endTime) }
        set { input.endTime = timeOfDay(from: newValue) }
    }

    /// The address section only applies when the shop delivers.
    var showsDeliveryAddress: Bool {
        input.deliveryMethod == .delivery
    }

    var recipientLine: String {
        input.hasSeparateRecipient ? AppStrings.recipient : AppStrings.recipientIsCustomer
    }

    var recipientToggleTitle: String {
        input.hasSeparateRecipient ? AppStrings.sameAsCustomer : AppStrings.change
    }

    var canRemoveItems: Bool {
        input.items.count > 1
    }

    var totalText: String {
        AppFormatters.money(input.pricing.total)
    }

    var remainingText: String {
        AppFormatters.money(input.pricing.remaining)
    }

    /// "Lưu đơn · 1.200.000đ"
    var saveButtonTitle: String {
        "\(AppStrings.saveOrder) · \(totalText)"
    }

    /// First validation problem, shown above the save button. `nil` when the order can be saved.
    var validationHint: String? {
        validationError?.message
    }

    var canSave: Bool {
        validationError == nil
    }

    // MARK: - Actions

    func selectToday() {
        input.deliveryDate = calendar.startOfDay(for: now())
    }

    func selectTomorrow() {
        input.deliveryDate = calendar.startOfDay(for: tomorrow)
    }

    func select(_ option: TimeSlotOption) {
        if let window = option.window {
            input.hasTimeWindow = true
            input.startTime = window.start
            input.endTime = window.end
        } else {
            input.hasTimeWindow = false
        }
    }

    func addItem() {
        input.items.append(OrderItemInput())
    }

    func removeItem(id: OrderItemInput.ID) {
        guard canRemoveItems else { return }
        input.items.removeAll { $0.id == id }
    }

    func toggleSeparateRecipient() {
        input.hasSeparateRecipient.toggle()
        if !input.hasSeparateRecipient {
            input.recipientName = ""
            input.recipientPhone = ""
        }
    }

    func save() async {
        guard !isSaving else { return }
        if let hint = validationHint {
            errorMessage = hint
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let order = try await createOrderUseCase.execute(input, shopId: shop.id, actor: actor)
            onSaved(order)
        } catch let error as OrderError {
            errorMessage = error.message
        } catch {
            errorMessage = AppStrings.somethingWentWrong
        }
    }

    func cancel() {
        onCancel()
    }

    // MARK: - Private

    private var tomorrow: Date {
        calendar.date(byAdding: .day, value: 1, to: now()) ?? now()
    }

    private var validationError: OrderError? {
        do {
            _ = try OrderDraft(input)
            return nil
        } catch let error as OrderError {
            return error
        } catch {
            return nil
        }
    }

    private func date(at time: TimeOfDay) -> Date {
        calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: input.deliveryDate) ?? input.deliveryDate
    }

    private func timeOfDay(from date: Date) -> TimeOfDay {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return TimeOfDay(hour: components.hour ?? 0, minute: components.minute ?? 0)
    }
}
