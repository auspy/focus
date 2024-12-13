import SwiftUI

enum AppColors {
    static let primary = Color(hex: "#007AFF")  // Apple's default blue
    static let primaryLight = primary.opacity(0.2)
    
    // Background colors
    static let background = Color(NSColor.windowBackgroundColor)
    
    // Text colors
    static let secondaryText = Color.secondary
    
    // Button colors
    static let buttonTint = primary
    static let buttonDisabled = Color.secondary
} 