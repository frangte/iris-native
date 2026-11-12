//
//  DSFont.swift
//  iris
//
//  Created by SonnyHoang on 11/11/26.
//

import SwiftUI

public struct DSFont {
    public static let displayLarge = Font.largeTitle.weight(.bold)
    public static let displayMedium = Font.title.weight(.bold)
    public static let displaySmall = Font.title2.weight(.bold)
    
    public static let headlineLarge = Font.title2.weight(.semibold)
    public static let headlineMedium = Font.title3.weight(.semibold)
    public static let headlineSmall = Font.headline.weight(.semibold)
    
    public static let bodyLarge = Font.body
    public static let bodyMedium = Font.callout
    public static let bodySmall = Font.caption
    
    public static let labelLarge = Font.callout.weight(.medium)
    public static let labelMedium = Font.caption.weight(.medium)
    public static let labelSmall = Font.caption2.weight(.medium)
}
