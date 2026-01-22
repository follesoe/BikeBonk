//
//  Theme.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

/// App-wide theme defining the visual states for the bike mount warning system.
enum Theme {

    /// Warning state when bikes are mounted on the roof.
    enum Warning {
        static let gradientStart = Color(hex: "FF2D20")
        static let gradientMiddle = Color(hex: "FF5733")
        static let gradientEnd = Color(hex: "FF8C42")

        static let gradient = LinearGradient(
            colors: [gradientStart, gradientMiddle, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let icon = "bicycle"
        static let badgeIcon = "exclamationmark.triangle.fill"
        static let statusKey = "bikes_status_mounted"
    }

    /// Safe state when no bikes are mounted.
    enum Safe {
        static let gradientStart = Color(hex: "34C759")
        static let gradientMiddle = Color(hex: "30D158")
        static let gradientEnd = Color(hex: "30B350")

        static let gradient = LinearGradient(
            colors: [gradientStart, gradientMiddle, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let icon = "car.fill"
        static let badgeIcon = "checkmark.circle.fill"
        static let statusKey = "bikes_status_not_mounted"
    }

    /// Returns the appropriate gradient for the current state.
    static func gradient(for bikesMounted: Bool) -> LinearGradient {
        bikesMounted ? Warning.gradient : Safe.gradient
    }

    /// Returns the appropriate icon name for the current state.
    static func icon(for bikesMounted: Bool) -> String {
        bikesMounted ? Warning.icon : Safe.icon
    }

    /// Returns the appropriate badge icon name for the current state.
    static func badgeIcon(for bikesMounted: Bool) -> String {
        bikesMounted ? Warning.badgeIcon : Safe.badgeIcon
    }

    /// Returns the localization key for the status text.
    static func statusKey(for bikesMounted: Bool) -> String {
        bikesMounted ? Warning.statusKey : Safe.statusKey
    }
}
