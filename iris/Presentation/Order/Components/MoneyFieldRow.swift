//
//  MoneyFieldRow.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Form line for a VND amount: label on the left, right-aligned grouped digits and "đ" on the right.
/// Shows "0" as a placeholder while the amount is zero.
struct MoneyFieldRow: View {
    let label: String
    @Binding var amount: Int

    /// Enough for amounts in the hundreds of billions; keeps `Int` parsing safe.
    private static let maxDigits = 12

    var body: some View {
        DSRow(label: label) {
            HStack(spacing: DSSpacing.xs) {
                TextField("0", text: text)
                    .font(DSFont.body.money)
                    .foregroundStyle(Color.label)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)

                Text(AppStrings.currencySymbol)
                    .font(DSFont.body)
                    .foregroundStyle(Color.secondaryLabel)
            }
        }
    }

    /// Formats on every change so the user sees "1.200.000" while typing digits.
    private var text: Binding<String> {
        Binding(
            get: { amount == 0 ? "" : AppFormatters.number(amount) },
            set: { amount = Self.parse($0) }
        )
    }

    private static func parse(_ raw: String) -> Int {
        let digits = raw.filter(\.isNumber).prefix(maxDigits)
        return Int(digits) ?? 0
    }
}

#Preview {
    @Previewable @State var fee = 0
    @Previewable @State var deposit = 500_000
    DSFormCard {
        MoneyFieldRow(label: AppStrings.shippingFee, amount: $fee)
        MoneyFieldRow(label: AppStrings.deposit, amount: $deposit)
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
