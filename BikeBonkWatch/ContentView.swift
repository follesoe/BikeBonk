//
//  ContentView.swift
//  BikeBonkWatch
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var sync = SyncManager.shared

    var body: some View {
        Button(action: {
            sync.setBikesMounted(!sync.bikesMounted)
            Feedback.play(forMountedState: sync.bikesMounted)
        }) {
            VStack(spacing: 8) {
                StatusIconView(bikesMounted: sync.bikesMounted, size: .watch)

                StatusTextView(bikesMounted: sync.bikesMounted, fontSize: 14)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.gradient(for: sync.bikesMounted))
        }
        .buttonStyle(.plain)
        .ignoresSafeArea()
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                sync.refresh()
            }
        }
    }
}

#Preview {
    ContentView()
}
