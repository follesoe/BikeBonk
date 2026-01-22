//
//  BikeState.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import Foundation
import WidgetKit

/// Shared state manager for bike-mounted status.
/// Uses iCloud Key-Value Store for cross-device sync and App Groups for local caching.
struct BikeState {
    static let appGroupID = "group.no.follesoe.BikeBonk.shared"
    static let bikesMountedKey = "bikesMounted"
    static let lastUpdatedKey = "bikesMountedLastUpdated"

    /// Shared UserDefaults instance using App Groups (local cache).
    static var shared: UserDefaults {
        UserDefaults(suiteName: appGroupID)!
    }

    /// iCloud Key-Value Store for cross-device sync.
    static var iCloud: NSUbiquitousKeyValueStore {
        NSUbiquitousKeyValueStore.default
    }

    /// Whether bikes are currently mounted on the roof.
    /// Reads from local cache, writes to both local and iCloud.
    static var bikesMounted: Bool {
        get { shared.bool(forKey: bikesMountedKey) }
        set {
            // Write to local cache with timestamp
            shared.set(newValue, forKey: bikesMountedKey)
            shared.set(Date().timeIntervalSince1970, forKey: lastUpdatedKey)
            // Write to iCloud
            iCloud.set(newValue, forKey: bikesMountedKey)
            iCloud.synchronize()
            // Reload widget timelines when state changes
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Returns true if local cache was updated within the last few seconds.
    static var wasRecentlyUpdatedLocally: Bool {
        let lastUpdated = shared.double(forKey: lastUpdatedKey)
        let elapsed = Date().timeIntervalSince1970 - lastUpdated
        return elapsed < 5.0  // Within last 5 seconds
    }

    /// Toggles the bikes mounted state and reloads widgets.
    static func toggle() {
        bikesMounted.toggle()
    }

    /// Syncs local state from iCloud. Call this when iCloud notifies of external changes.
    static func syncFromiCloud() {
        let iCloudValue = iCloud.bool(forKey: bikesMountedKey)
        let localValue = shared.bool(forKey: bikesMountedKey)
        if iCloudValue != localValue {
            shared.set(iCloudValue, forKey: bikesMountedKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
