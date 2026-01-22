//
//  BikeState.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import Foundation
import WidgetKit

/// Shared state manager for bike-mounted status.
/// Uses App Groups to share data between the main app and widgets.
struct BikeState {
    static let appGroupID = "group.no.follesoe.BikeBonk.shared"
    static let bikesMountedKey = "bikesMounted"

    /// Shared UserDefaults instance using App Groups.
    static var shared: UserDefaults {
        UserDefaults(suiteName: appGroupID)!
    }

    /// Whether bikes are currently mounted on the roof.
    static var bikesMounted: Bool {
        get { shared.bool(forKey: bikesMountedKey) }
        set {
            shared.set(newValue, forKey: bikesMountedKey)
            // Reload widget timelines when state changes
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Toggles the bikes mounted state and reloads widgets.
    static func toggle() {
        bikesMounted.toggle()
    }
}
