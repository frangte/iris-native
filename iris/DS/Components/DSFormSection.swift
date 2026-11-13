//
//  DSFormSection.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Uppercase section title, arbitrary content, and an optional footer note.
/// Mirrors the grouped-form look of system settings screens.
struct DSFormSection<Content: View>: View {
    let title: String
    let footer: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title.uppercased())
                .font(DSFont.footnote)
                .foregroundStyle(Color.secondaryLabel)
                .padding(.horizontal, DSSpacing.controlInset)

            content

            if let footer {
                Text(footer)
                    .font(DSFont.footnote)
                    .foregroundStyle(Color.secondaryLabel)
                    .padding(.horizontal, DSSpacing.controlInset)
            }
        }
    }
}

#Preview {
    @Previewable @State var name = ""
    DSFormSection(title: AppStrings.openNewShop, footer: AppStrings.youAreOwner) {
        DSFormCard {
            DSFormRow(label: AppStrings.shopName, placeholder: AppStrings.shopNamePlaceHolder, text: $name)
        }
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
