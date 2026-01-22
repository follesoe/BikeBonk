//
//  StatusIconView.swift
//  BikeBonk
//
//  Shared icon component used across iOS, widget, and watchOS apps.
//

import SwiftUI

/// Displays the status icon with an overlay badge indicating the current bike mount state.
struct StatusIconView: View {
    let bikesMounted: Bool
    let iconSize: CGFloat
    let badgeSize: CGFloat

    /// Creates a status icon with the specified sizes.
    /// - Parameters:
    ///   - bikesMounted: Whether bikes are currently mounted on the roof.
    ///   - iconSize: The size of the main icon (default: 120 for iOS).
    ///   - badgeSize: The size of the badge overlay (default: 36 for iOS).
    init(bikesMounted: Bool, iconSize: CGFloat = 120, badgeSize: CGFloat = 36) {
        self.bikesMounted = bikesMounted
        self.iconSize = iconSize
        self.badgeSize = badgeSize
    }

    /// Preset sizes for different contexts.
    enum Size {
        case iOS
        case widget
        case widgetMedium
        case watch

        var iconSize: CGFloat {
            switch self {
            case .iOS: return 120
            case .widget: return 44
            case .widgetMedium: return 64
            case .watch: return 50
            }
        }

        var badgeSize: CGFloat {
            switch self {
            case .iOS: return 36
            case .widget: return 16
            case .widgetMedium: return 20
            case .watch: return 18
            }
        }

        var badgeOffset: CGPoint {
            switch self {
            case .iOS: return CGPoint(x: 20, y: -10)
            case .widget: return CGPoint(x: 8, y: -4)
            case .widgetMedium: return CGPoint(x: 12, y: -6)
            case .watch: return CGPoint(x: 10, y: -5)
            }
        }
    }

    /// Creates a status icon with a preset size.
    init(bikesMounted: Bool, size: Size) {
        self.bikesMounted = bikesMounted
        self.iconSize = size.iconSize
        self.badgeSize = size.badgeSize
        self._badgeOffset = size.badgeOffset
    }

    private var _badgeOffset: CGPoint = CGPoint(x: 20, y: -10)

    private var badgeOffset: CGPoint {
        // Calculate proportional offset based on icon size if not using preset
        let ratio = iconSize / 120.0
        return CGPoint(x: 20 * ratio, y: -10 * ratio)
    }

    var body: some View {
        Image(systemName: Theme.icon(for: bikesMounted))
            .font(.system(size: iconSize, weight: .medium))
            .foregroundColor(.white)
            .overlay(alignment: .topTrailing) {
                Image(systemName: Theme.badgeIcon(for: bikesMounted))
                    .font(.system(size: badgeSize, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: _badgeOffset.x, y: _badgeOffset.y)
            }
    }
}

/// Displays the localized status text for the current bike mount state.
struct StatusTextView: View {
    let bikesMounted: Bool
    let fontSize: CGFloat

    init(bikesMounted: Bool, fontSize: CGFloat = 32) {
        self.bikesMounted = bikesMounted
        self.fontSize = fontSize
    }

    var body: some View {
        Text(String(localized: String.LocalizationValue(Theme.statusKey(for: bikesMounted))))
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
}

#Preview("Safe State") {
    ZStack {
        Theme.Safe.gradient.ignoresSafeArea()
        VStack(spacing: 24) {
            StatusIconView(bikesMounted: false, size: .iOS)
            StatusTextView(bikesMounted: false)
        }
    }
}

#Preview("Warning State") {
    ZStack {
        Theme.Warning.gradient.ignoresSafeArea()
        VStack(spacing: 24) {
            StatusIconView(bikesMounted: true, size: .iOS)
            StatusTextView(bikesMounted: true)
        }
    }
}
