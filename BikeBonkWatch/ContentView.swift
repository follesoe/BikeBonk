//
//  ContentView.swift
//  BikeBonkWatch
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var bikesMounted = BikeState.bikesMounted

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
        }
        .onAppear {
            bikesMounted = BikeState.bikesMounted
        }
    }
}

#Preview {
    ContentView()
}
