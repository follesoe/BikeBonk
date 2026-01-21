//
//  Theme.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

/// App-wide color theme defining the visual states for the bike mount warning system.
enum Theme {

    /// Colors for the warning state when bikes are mounted on the roof.
    enum Warning {
        static let gradientStart = Color(hex: "FF2D20")
        static let gradientMiddle = Color(hex: "FF5733")
        static let gradientEnd = Color(hex: "FF8C42")

        static let gradient = LinearGradient(
            colors: [gradientStart, gradientMiddle, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Colors for the safe state when no bikes are mounted.
    enum Safe {
        static let gradientStart = Color(hex: "34C759")
        static let gradientMiddle = Color(hex: "30D158")
        static let gradientEnd = Color(hex: "30B350")

        static let gradient = LinearGradient(
            colors: [gradientStart, gradientMiddle, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
