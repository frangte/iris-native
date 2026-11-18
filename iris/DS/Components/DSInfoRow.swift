//
//  DSInfoRow.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Read-only list line: optional leading icon, title with an optional subtitle, and any trailing view.
/// Intended to be placed inside `DSFormCard`.
struct DSInfoRow<Trailing: View>: View {
    let systemImage: String?
    let title: String
    let subtitle: String?
    let trailing: Trailing

    init(
        systemImage: String? = nil,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.secondaryLabel)
                    .frame(width: DSSpacing.iconSize)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSFont.body)
                    .foregroundStyle(Color.label)
                if let subtitle {
                    Text(subtitle)
                        .font(DSFont.subhead)
                        .foregroundStyle(Color.secondaryLabel)
                }
            }

            Spacer(minLength: 0)

            trailing
        }
        .padding(.horizontal, DSSpacing.controlInset)
        .padding(.vertical, DSSpacing.sm)
        .frame(minHeight: DSSpacing.rowHeight)
    }
}

extension DSInfoRow where Trailing == EmptyView {
    init(systemImage: String? = nil, title: String, subtitle: String? = nil) {
        self.init(systemImage: systemImage, title: title, subtitle: subtitle) { EmptyView() }
    }
}

#Preview {
    DSFormCard {
        DSInfoRow(systemImage: "person.crop.circle", title: "Chị Thảo", subtitle: "0909 123 456") {
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.tertiaryLabel)
        }
        DSInfoRow(systemImage: "map", title: AppStrings.noAddress, subtitle: AppStrings.tapEditToAdd)
        DSInfoRow(title: AppStrings.createdOrder, subtitle: "abc@abc.com · 19:35 · 16/11")
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
