//
//  DSFont.swift
//  iris
//
//  Created by SonnyHoang on 11/11/26.
//

import SwiftUI

/// Typography tokens. Names and weights mirror the iOS text styles listed in
/// the design system (design-system.json → typographyMeta), so Dynamic Type
/// scaling comes from the system for free.
public enum DSFont {
    // MARK: - Titles

    /// 34/41 · bold. Navigation large titles; the order remaining amount.
    public static let largeTitle = Font.largeTitle.weight(.bold)
    /// 28/34 · bold. Order customer name on detail; invite code.
    public static let title1 = Font.title.weight(.bold)
    /// 22/28 · bold. Summary tile values; order-form remaining.
    public static let title2 = Font.title2.weight(.bold)
    /// 20/25 · semibold. Shop name row heading.
    public static let title3 = Font.title3.weight(.semibold)

    // MARK: - Text

    /// 17/22 · semibold. Order row names, button labels, empty titles.
    public static let headline = Font.headline
    /// 17/22 · regular. Row titles and field input.
    public static let body = Font.body
    /// 16/21 · regular. Order date line on detail.
    public static let callout = Font.callout
    /// 15/20 · regular. Row subtitles, money lines, chips, small buttons, toast.
    public static let subhead = Font.subheadline
    /// 13/18 · regular. Uppercase grouped section headers, footers, tile labels, segments.
    public static let footnote = Font.footnote
    /// 12/16 · regular. Web bottom tab labels.
    public static let caption = Font.caption
    /// 12/16 · semibold. Status pills.
    public static let captionEmphasized = Font.caption.weight(.semibold)
}

public extension Font {
    /// Tabular figures for every amount and count (the `money` modifier in the design system).
    /// Usage: `.font(DSFont.largeTitle.money)`.
    var money: Font { monospacedDigit() }
}
