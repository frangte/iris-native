//
//  DSSpacing.swift
//  iris
//
//  Created by SonnyHoang on 11/11/26.
//

import CoreGraphics

/// Layout tokens: spacing scale, corner radii and control heights from the
/// design system (design-system.html → Spacing · Radius).
public enum DSSpacing {
    private static let baseUnit: CGFloat = 4

    // MARK: - Spacing scale

    public static let xs = baseUnit * 1   // 4
    public static let sm = baseUnit * 2   // 8
    public static let md = baseUnit * 3   // 12
    public static let lg = baseUnit * 4   // 16
    public static let xl = baseUnit * 6   // 24
    public static let xxl = baseUnit * 8  // 32

    // MARK: - Semantic spacing

    /// Horizontal inset between screen edge and content.
    public static let screenPadding = lg
    /// Horizontal inset of text inside rows, fields and buttons, and of
    /// section titles/footers. Also the leading inset of row separators.
    public static let controlInset = lg

    // MARK: - Corner radius

    /// Small controls (e.g. text inputs drawn outside a cell).
    public static let controlRadius: CGFloat = 10
    /// Grouped cells, cards and buttons.
    public static let cellRadius: CGFloat = 12
    /// Fully rounded capsules: chips and status pills.
    public static let pillRadius: CGFloat = 999

    // MARK: - Heights

    /// Filled, tinted and destructive buttons.
    public static let buttonHeight: CGFloat = 50
    /// Small buttons and selectable chips.
    public static let smallButtonHeight: CGFloat = 36
    /// Grouped list rows and field rows.
    public static let rowHeight: CGFloat = 48
    /// Segmented control track.
    public static let segmentedHeight: CGFloat = 32
    /// Inline icon size.
    public static let iconSize: CGFloat = 20
}
