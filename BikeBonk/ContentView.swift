//
//  ContentView.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var sync = SyncManager.shared

    /// Binding that syncs toggle changes through SyncManager.
    private var bikesMountedBinding: Binding<Bool> {
        Binding(
            get: { sync.bikesMounted },
            set: { newValue in
                sync.setBikesMounted(newValue)
                Feedback.play(forMountedState: newValue)
            }
        )
    }

    var body: some View {
        ZStack {
            Theme.gradient(for: sync.bikesMounted)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                StatusIconView(bikesMounted: sync.bikesMounted, size: .iOS)
                    .onTapGesture(count: 2) {
                        sync.setBikesMounted(!sync.bikesMounted)
                        Feedback.play(forMountedState: sync.bikesMounted)
                    }
                    .accessibilityHidden(true)

                StatusTextView(bikesMounted: sync.bikesMounted)
                    .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    Text("bikes_toggle_label")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Toggle("", isOn: bikesMountedBinding)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .scaleEffect(1.3)
                        .tint(.white.opacity(0.3))
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.3), value: sync.bikesMounted)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                sync.refresh()
            }
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
