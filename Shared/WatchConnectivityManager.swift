//
//  WatchConnectivityManager.swift
//  BikeBonk
//
//  Handles state synchronization between iOS and watchOS using Watch Connectivity.
//

import Foundation
import Combine
import WatchConnectivity

/// Manages Watch Connectivity session for syncing bike state between iPhone and Apple Watch.
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    /// Published property that updates when bike state changes from the counterpart device.
    @Published var bikesMounted: Bool = BikeState.bikesMounted

    /// Flag to prevent ping-pong when receiving updates from counterpart.
    @Published var isReceivingUpdate: Bool = false

    private let bikesMountedKey = "bikesMounted"

    private override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        guard WCSession.isSupported() else {
            print("WatchConnectivity: Not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Check if there's a pending context update from the counterpart and apply it.
    @MainActor
    func syncReceivedContext() {
        guard WCSession.default.activationState == .activated else { return }

        if let bikesMounted = WCSession.default.receivedApplicationContext[bikesMountedKey] as? Bool {
            if bikesMounted != self.bikesMounted {
                print("WatchConnectivity: Applying received context - bikesMounted: \(bikesMounted)")
                isReceivingUpdate = true
                BikeState.bikesMounted = bikesMounted
                self.bikesMounted = bikesMounted
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    self.isReceivingUpdate = false
                }
            }
        }
    }

    /// Call this when the local bike state changes to sync with the counterpart device.
    @MainActor
    func sendStateUpdate(bikesMounted: Bool) {
        guard WCSession.default.activationState == .activated else {
            print("WatchConnectivity: Session not activated")
            return
        }

        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            print("WatchConnectivity: Watch app not installed")
            return
        }
        #endif

        // Use applicationContext for state that should always reflect the latest value
        do {
            try WCSession.default.updateApplicationContext([bikesMountedKey: bikesMounted])
            print("WatchConnectivity: Sent state update - bikesMounted: \(bikesMounted)")
        } catch {
            print("WatchConnectivity: Failed to send state - \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivity: Activation failed - \(error.localizedDescription)")
            return
        }
        print("WatchConnectivity: Activated with state: \(activationState.rawValue)")

        // Sync current state after activation
        Task { @MainActor in
            sendStateUpdate(bikesMounted: BikeState.bikesMounted)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let bikesMounted = applicationContext[bikesMountedKey] as? Bool else {
            return
        }

        print("WatchConnectivity: Received state update - bikesMounted: \(bikesMounted)")

        Task { @MainActor in
            // Set flag to prevent ping-pong
            self.isReceivingUpdate = true
            // Update local state
            BikeState.bikesMounted = bikesMounted
            self.bikesMounted = bikesMounted
            // Reset flag after a short delay to allow UI to update
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            self.isReceivingUpdate = false
        }
    }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("WatchConnectivity: Session became inactive")
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("WatchConnectivity: Session deactivated, reactivating...")
        session.activate()
    }
    #endif
}
