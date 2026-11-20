//
//  InviteCodeCard.swift
//  iris
//
//  Created by SonnyHoang on 20/11/26.
//

import SwiftUI

/// One invite code: the code in large spaced letters, its expiry and use count,
/// a share button and a revoke button. Intended to be placed inside `DSFormCard`.
struct InviteCodeCard: View {
    let invite: ShopMembersViewModel.InviteCard
    let isRevoking: Bool
    let onRevoke: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text(invite.code)
                .font(DSFont.largeTitle)
                .kerning(DSSpacing.sm)
                .foregroundStyle(Color.label)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.lg)
                .background(Color.fill, in: RoundedRectangle(cornerRadius: DSSpacing.cellRadius))
                .textSelection(.enabled)
                .accessibilityLabel(invite.code.map(String.init).joined(separator: " "))

            Text(invite.detail)
                .font(DSFont.subhead)
                .foregroundStyle(Color.secondaryLabel)

            HStack(spacing: DSSpacing.md) {
                ShareLink(item: invite.shareMessage) {
                    DSPrimaryLabel(title: AppStrings.sendCode, systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)

                Button(action: onRevoke) {
                    ZStack {
                        Text(AppStrings.revoke)
                            .font(DSFont.headline)
                            .foregroundStyle(Color.tint)
                            .opacity(isRevoking ? 0 : 1)
                        if isRevoking {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal, DSSpacing.lg)
                    .frame(height: DSSpacing.buttonHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isRevoking)
            }
        }
        .padding(DSSpacing.controlInset)
    }
}

#Preview {
    DSFormCard {
        InviteCodeCard(
            invite: .init(id: "CQ4AD2", code: "CQ4AD2", detail: "Hết hạn 27/11 · đã dùng 0 lần", shareMessage: "CQ4AD2"),
            isRevoking: false,
            onRevoke: {}
        )
        DSActionRow(title: AppStrings.createInviteCode, systemImage: "ticket") {}
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
