//
//  ContentView.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var bikesMounted = BikeState.bikesMounted
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var connectivityManager = WatchConnectivityManager.shared

    var body: some View {
        ZStack {
            Theme.gradient(for: bikesMounted)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                StatusIconView(bikesMounted: bikesMounted, size: .iOS)
                    .onTapGesture(count: 2) {
                        bikesMounted.toggle()
                    }
                    .accessibilityHidden(true)

                StatusTextView(bikesMounted: bikesMounted)
                    .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    Text("bikes_toggle_label")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Toggle("", isOn: $bikesMounted)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .scaleEffect(1.3)
                        .tint(.white.opacity(0.3))
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.3), value: bikesMounted)
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
                // Sync to watch in case state was changed by widget
                connectivityManager.sendStateUpdate(bikesMounted: BikeState.bikesMounted)
            }
        }
        .onChange(of: connectivityManager.bikesMounted) { _, newValue in
            bikesMounted = newValue
        }
        .preferredColorScheme(.dark)
    }
}
#Preview("Safe State") {
    ContentView()
}

#Preview("Warning State") {
    ContentView()
        .onAppear {
            BikeState.bikesMounted = true
        }
}
