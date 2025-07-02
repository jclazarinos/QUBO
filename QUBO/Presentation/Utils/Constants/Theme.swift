// MARK: - Presentation/Utils/Constants/Theme.swift
import SwiftUI

struct AppTheme {
    // Colors
    static let primaryColor = Color.snesRed
    static let secondaryColor = Color.arcadeYellow
    static let accentColor = Color.retroBlue
    static let backgroundColor = Color.lightGray
    static let textColor = Color.darkGray
    
    // Fonts
    static let largeTitle = Font.pixelTitle
    static let title = Font.pixelHeading
    static let body = Font.pixelBody
    static let caption = Font.pixelCaption
    
    // Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // Corner Radius
    static let smallCornerRadius: CGFloat = 4
    static let mediumCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 12
    
    // Dimensions
    static let sidebarWidth: CGFloat = 250
    static let gameCardHeight: CGFloat = 120
    static let largeIconSize: CGFloat = 48
    static let mediumIconSize: CGFloat = 32
    static let smallIconSize: CGFloat = 16
}
