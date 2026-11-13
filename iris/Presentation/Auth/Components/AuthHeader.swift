//
//  AuthHeader.swift
//  iris
//
//  Created by SonnyHoang on 12/11/26.
//

import SwiftUI

/// App name and tagline shown at the top of the login screen.
struct AuthHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Floied")
                .font(DSFont.largeTitle)
                .foregroundStyle(Color.label)
            Text(AppStrings.orderBookTitle)
                .font(DSFont.subhead)
                .foregroundStyle(Color.secondaryLabel)
        }
    }
}

#Preview {
    AuthHeader()
        .padding(DSSpacing.md)
}
