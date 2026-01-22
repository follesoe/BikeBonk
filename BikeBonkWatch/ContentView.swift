//
//  ContentView.swift
//  BikeBonkWatch
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var bikesMounted = BikeState.bikesMounted
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var connectivityManager = WatchConnectivityManager.shared

    var body: some View {
        Button(action: {
            bikesMounted.toggle()
        }) {
            VStack(spacing: 8) {
                StatusIconView(bikesMounted: bikesMounted, size: .watch)

                StatusTextView(bikesMounted: bikesMounted, fontSize: 14)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.gradient(for: bikesMounted))
        }
        .buttonStyle(.plain)
        .ignoresSafeArea()
        .onChange(of: bikesMounted) { _, newValue in
            BikeState.bikesMounted = newValue
            Feedback.play(forMountedState: newValue)
            // Only sync if this is a local change, not a received update
            if !connectivityManager.isReceivingUpdate {
                connectivityManager.sendStateUpdate(bikesMounted: newValue)
            }
        }
        .onAppear {
            bikesMounted = BikeState.bikesMounted
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // First check if counterpart sent us an update
                connectivityManager.syncReceivedContext()
                // Then update UI from local state
                bikesMounted = BikeState.bikesMounted
                // Sync to iPhone in case state was changed by complication
                connectivityManager.sendStateUpdate(bikesMounted: BikeState.bikesMounted)
            }
        }
        .onChange(of: connectivityManager.bikesMounted) { _, newValue in
            bikesMounted = newValue
        }
    }
}

#Preview {
    ContentView()
}
