//
//  DSFlowLayout.swift
//  iris
//
//  Created by SonnyHoang on 16/11/26.
//

import SwiftUI

/// Lays children out left to right and wraps to a new line when the width runs out.
/// Used for chip groups whose count and widths vary.
struct DSFlowLayout: Layout {
    var spacing: CGFloat = DSSpacing.sm
    var lineSpacing: CGFloat = DSSpacing.md

    private struct Arrangement {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let arrangement = arrange(in: proposal.width ?? .infinity, subviews: subviews)
        // Fill the proposed width so the container aligns like a regular stack.
        return CGSize(width: proposal.width ?? arrangement.size.width, height: arrangement.size.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(in: bounds.width, subviews: subviews)
        for (subview, frame) in zip(subviews, arrangement.frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    /// Greedy line breaking: each child goes on the current line if it fits, otherwise starts a new one.
    private func arrange(in maxWidth: CGFloat, subviews: Subviews) -> Arrangement {
        var arrangement = Arrangement()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            arrangement.frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
            arrangement.size.width = max(arrangement.size.width, x - spacing)
        }
        arrangement.size.height = y + lineHeight
        return arrangement
    }
}

#Preview {
    DSFlowLayout {
        ForEach([AppStrings.sourceZalo, AppStrings.sourceMessenger, AppStrings.sourceTikTok, AppStrings.sourceInstagram, AppStrings.sourcePhoneCall, AppStrings.sourceWalkIn, AppStrings.sourceOther], id: \.self) { title in
            DSChip(title: title, isSelected: title == AppStrings.sourceZalo) {}
        }
    }
    .padding(DSSpacing.screenPadding)
    .background(Color.groupedBackground)
}
