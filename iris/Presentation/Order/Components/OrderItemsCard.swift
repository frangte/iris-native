//
//  OrderItemsCard.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Product lines of the order: name, quantity stepper and unit price per line, then an add row.
/// The delete row appears only while more than one line exists.
struct OrderItemsCard: View {
    @Binding var items: [OrderItemInput]
    let canRemove: Bool
    let onAdd: () -> Void
    let onRemove: (OrderItemInput.ID) -> Void

    var body: some View {
        DSFormCard {
            ForEach($items) { $item in
                DSFormRow(
                    label: nil,
                    placeholder: AppStrings.productNamePlaceholder,
                    text: $item.name
                )
                DSRow(label: AppStrings.amount) {
                    DSStepper(value: $item.quantity)
                }
                MoneyFieldRow(label: AppStrings.price, amount: $item.unitPrice)

                if canRemove {
                    DSActionRow(title: AppStrings.deleteProduct, systemImage: "trash", style: .destructive) {
                        onRemove(item.id)
                    }
                }
            }

            DSActionRow(title: AppStrings.addProduct, systemImage: "plus", action: onAdd)
        }
    }
}

#Preview {
    @Previewable @State var items = [OrderItemInput(), OrderItemInput(name: "Bó tulip", quantity: 2, unitPrice: 350_000)]
    OrderItemsCard(
        items: $items,
        canRemove: items.count > 1,
        onAdd: { items.append(OrderItemInput()) },
        onRemove: { id in items.removeAll { $0.id == id } }
    )
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
