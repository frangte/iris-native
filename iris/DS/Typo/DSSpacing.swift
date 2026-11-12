//
//  DSSpacing.swift
//  iris
//
//  Created by SonnyHoang on 11/11/26.
//

import SwiftUI

public struct DSSpacing {
    private static let baseUnit = 4.0
    
    // spacing scale
    public static let xs = baseUnit * 1
    public static let sm = baseUnit * 2
    public static let md = baseUnit * 3
    public static let lg = baseUnit * 4
    public static let xl = baseUnit * 6
    public static let xxl = baseUnit * 8
    
    public static let buttonPadding = md
    public static let cardPadding = lg
    public static let sectionPadding = xl
    public static let screenPadding = md
}
