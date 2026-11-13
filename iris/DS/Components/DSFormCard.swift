//
//  DSFormCard.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Rounded card that stacks its children vertically with an inset divider between each pair.
struct DSFormCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { subviews in
                ForEach(subviews) { subview in
                    subview

                    if subview.id != subviews.last?.id {
                        Divider()
                            .padding(.leading, DSSpacing.controlInset)
                    }
                }
            }
        }
        .background(Color.cell, in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
    }
}

#Preview {
    @Previewable @State var name = ""
    @Previewable @State var phone = ""
    DSFormCard {
        DSFormRow(label: AppStrings.shopName, placeholder: AppStrings.shopNamePlaceHolder, text: $name)
        DSFormRow(label: AppStrings.phoneNumber, placeholder: AppStrings.optional, text: $phone, keyboardType: .phonePad)
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
