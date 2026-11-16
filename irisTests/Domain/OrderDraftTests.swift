//
//  OrderDraftTests.swift
//  irisTests
//
//  Created by SonnyHoang on 16/11/26.
//

import Foundation
import Testing
@testable import iris

struct OrderDraftTests {
    private let day = Date(timeIntervalSince1970: 1_800_000_000)

    private func makeInput() -> OrderInput {
        var input = OrderInput(deliveryDate: day)
        input.items[0].name = "Bó hồng đỏ"
        input.items[0].unitPrice = 200_000
        return input
    }

    private func error(for input: OrderInput) -> OrderError? {
        do {
            _ = try OrderDraft(input)
            return nil
        } catch {
            return error as? OrderError
        }
    }

    @Test func emptyFormHasNoItems() {
        #expect(error(for: OrderInput(deliveryDate: day)) == .noItems)
    }

    @Test func blankLinesAreDroppedAndPricedLinesNeedAName() throws {
        var input = makeInput()
        input.items.append(OrderItemInput())

        let draft = try OrderDraft(input)
        #expect(draft.items.count == 1)

        input.items[1].unitPrice = 50_000
        #expect(error(for: input) == .missingItemName)
    }

    @Test func trimsOptionalTextAndDropsEmptyOnes() throws {
        var input = makeInput()
        input.customerName = "  Chị Thảo  "
        input.customerPhone = "   "
        input.note = " giấy gói kraft "

        let draft = try OrderDraft(input)

        #expect(draft.customerName == "Chị Thảo")
        #expect(draft.customerPhone == nil)
        #expect(draft.note == "giấy gói kraft")
        #expect(draft.recipient == nil)
        #expect(draft.timeWindow == nil)
    }

    @Test func pricingSumsLinesAndAppliesFees() throws {
        var input = makeInput()
        input.items[0].quantity = 3
        input.shippingFee = 30_000
        input.discount = 20_000
        input.deposit = 100_000

        let draft = try OrderDraft(input)

        #expect(draft.pricing.subtotal == 600_000)
        #expect(draft.pricing.total == 610_000)
        #expect(draft.pricing.remaining == 510_000)
    }

    @Test func rejectsDiscountAndDepositAboveTotals() {
        var input = makeInput()
        input.discount = 250_000
        #expect(error(for: input) == .discountExceedsTotal)

        input.discount = 0
        input.deposit = 250_000
        #expect(error(for: input) == .depositExceedsTotal)
    }

    @Test func rejectsTimeWindowThatEndsBeforeItStarts() throws {
        var input = makeInput()
        input.hasTimeWindow = true
        input.startTime = TimeOfDay(hour: 10)
        input.endTime = TimeOfDay(hour: 10)
        #expect(error(for: input) == .endTimeNotAfterStart)

        input.endTime = TimeOfDay(hour: 12)
        #expect(try OrderDraft(input).timeWindow == DeliveryTimeWindow(start: TimeOfDay(hour: 10), end: TimeOfDay(hour: 12)))
    }

    @Test func separateRecipientNeedsAName() throws {
        var input = makeInput()
        input.hasSeparateRecipient = true
        #expect(error(for: input) == .missingRecipientName)

        input.recipientName = "Anh Nam"
        input.recipientPhone = "0909"
        #expect(try OrderDraft(input).recipient == OrderRecipient(name: "Anh Nam", phone: "0909"))
    }

    @Test func pickupDropsAddress() throws {
        var input = makeInput()
        input.address = "12 Lê Lợi"
        input.deliveryMethod = .pickup

        #expect(try OrderDraft(input).address == nil)
    }
}
