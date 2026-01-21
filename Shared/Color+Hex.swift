//
//  Color+Hex.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

extension Color {

    /// Creates a SwiftUI Color from a hexadecimal color string.
    ///
    /// This initializer provides a convenient way to create colors using hex codes,
    /// which is common when working with design specifications or web colors.
    ///
    /// Supported formats:
    /// - 6-character RGB: `"FF5733"` or `"#FF5733"`
    /// - 8-character ARGB: `"80FF5733"` (with alpha channel)
    ///
    /// - Parameter hex: A hexadecimal color string. The `#` prefix is optional.
    ///
    /// - Note: Invalid hex strings default to black. For production apps requiring
    ///   dark mode support or accessibility variants, consider using Asset Catalog
    ///   colors instead.
    ///
    /// ## Example
    /// ```swift
    /// let red = Color(hex: "FF0000")
    /// let semiTransparentBlue = Color(hex: "800000FF")
    /// ```
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
