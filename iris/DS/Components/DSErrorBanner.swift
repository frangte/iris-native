//
//  DSErrorBanner.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// Inline error message on a soft danger background.
struct DSErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(DSFont.subhead)
            .foregroundStyle(Color.danger)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.controlInset)
            .padding(.vertical, DSSpacing.md)
            .background(Color.dangerSoft, in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

#Preview {
    DSErrorBanner(message: AppStrings.invalidEmail)
        .padding(DSSpacing.screenPadding)
}
