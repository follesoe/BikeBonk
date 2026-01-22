//
//  iCloudSyncManager.swift
//  BikeBonk
//
//  Handles iCloud Key-Value Store sync for bike state across devices.
//

import Foundation
import Combine

/// Manages iCloud Key-Value Store sync for bike state.
/// Observes external changes and publishes updates to the UI.
final class iCloudSyncManager: NSObject, ObservableObject {
    static let shared = iCloudSyncManager()

    /// Published property that updates when bike state changes from iCloud.
    @Published var bikesMounted: Bool = BikeState.bikesMounted

    private override init() {
        super.init()
        setupiCloudObserver()
        // Initial sync from iCloud
        BikeState.iCloud.synchronize()
    }

    private func setupiCloudObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
    }

    @objc private func iCloudDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonRaw = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }

        let reason = reasonRaw
        print("iCloudSync: External change received, reason: \(reason)")

        // Check if our key was changed
        if let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
           changedKeys.contains(BikeState.bikesMountedKey) {
            let newValue = BikeState.iCloud.bool(forKey: BikeState.bikesMountedKey)
            print("iCloudSync: bikesMounted changed to \(newValue)")

            Task { @MainActor in
                BikeState.syncFromiCloud()
                self.bikesMounted = newValue
            }
        }
    }

    /// Force a sync from iCloud and update the published property.
    @MainActor
    func refresh() {
        BikeState.iCloud.synchronize()
        let iCloudValue = BikeState.iCloud.bool(forKey: BikeState.bikesMountedKey)
        if iCloudValue != bikesMounted {
            BikeState.syncFromiCloud()
            bikesMounted = iCloudValue
        }
    }
}
