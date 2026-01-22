//
//  SyncManager.swift
//  BikeBonk
//
//  Unified sync manager that handles both Watch Connectivity (instant) and
//  iCloud Key-Value Store (background) synchronization.
//

import Foundation
import Combine
import WatchConnectivity
import WidgetKit

/// Unified manager for syncing bike state between iOS and watchOS.
/// Uses Watch Connectivity for instant sync when available, iCloud as fallback.
final class SyncManager: NSObject, ObservableObject {
    static let shared = SyncManager()

    /// The current bike-mounted state. Observe this for UI updates.
    @Published private(set) var bikesMounted: Bool = BikeState.bikesMounted

    private let stateKey = "bikesMounted"

    private override init() {
        super.init()
        setupWatchConnectivity()
        setupiCloudObserver()

        // Initial sync from iCloud
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    // MARK: - Public API

    /// Update the bike-mounted state. Syncs via Watch Connectivity (instant) and iCloud (background).
    @MainActor
    func setBikesMounted(_ newValue: Bool) {
        guard newValue != bikesMounted else { return }

        // Update local state
        bikesMounted = newValue
        BikeState.bikesMounted = newValue

        // Sync via Watch Connectivity (instant when reachable)
        sendViaWatchConnectivity(newValue)

        // iCloud is updated automatically via BikeState.bikesMounted setter
    }

    /// Refresh state from iCloud. Call when app becomes active.
    @MainActor
    func refresh() {
        NSUbiquitousKeyValueStore.default.synchronize()

        let iCloudValue = NSUbiquitousKeyValueStore.default.bool(forKey: stateKey)
        let localValue = BikeState.bikesMounted

        // Prefer iCloud value if different (it's the cross-device source of truth)
        if iCloudValue != localValue {
            BikeState.shared.set(iCloudValue, forKey: stateKey)
            WidgetCenter.shared.reloadAllTimelines()
        }

        // Update published state
        let currentValue = BikeState.bikesMounted
        if currentValue != bikesMounted {
            bikesMounted = currentValue
        }
    }

    // MARK: - Watch Connectivity

    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func sendViaWatchConnectivity(_ value: Bool) {
        guard WCSession.default.activationState == .activated else { return }

        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else { return }
        #endif

        let message = [stateKey: value]

        // Instant message when reachable
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { _ in }
        }

        // Application context as fallback (delivered when counterpart wakes)
        try? WCSession.default.updateApplicationContext(message)
    }

    // MARK: - iCloud

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
              let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
              changedKeys.contains(stateKey) else { return }

        let newValue = NSUbiquitousKeyValueStore.default.bool(forKey: stateKey)

        Task { @MainActor in
            self.applyReceivedState(newValue)
        }
    }

    // MARK: - Receiving State

    @MainActor
    private func applyReceivedState(_ newValue: Bool) {
        guard newValue != bikesMounted else { return }

        // Update local cache
        BikeState.shared.set(newValue, forKey: stateKey)

        // Reload widgets/complications
        WidgetCenter.shared.reloadAllTimelines()

        // Update published state (triggers UI update)
        bikesMounted = newValue
    }
}

// MARK: - WCSessionDelegate

extension SyncManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleWatchConnectivityMessage(message)
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        handleWatchConnectivityMessage(applicationContext)
    }

    private nonisolated func handleWatchConnectivityMessage(_ message: [String: Any]) {
        guard let newValue = message[stateKey] as? Bool else { return }

        Task { @MainActor in
            self.applyReceivedState(newValue)
        }
    }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
