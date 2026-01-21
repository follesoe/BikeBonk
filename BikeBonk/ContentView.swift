//
//  ContentView.swift
//  BikeBonk
//
//  Created by Jonas Follesø on 21/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var bikesMounted = BikeState.bikesMounted

    private var backgroundGradient: LinearGradient {
        bikesMounted ? Theme.Warning.gradient : Theme.Safe.gradient
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Main icon with double-tap gesture
                ZStack {
                    if bikesMounted {
                        Image(systemName: "bicycle")
                            .font(.system(size: 120, weight: .medium))
                            .foregroundColor(.white)
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: 20, y: -10)
                            }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 120, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture(count: 2) {
                    bikesMounted.toggle()
                }
                .accessibilityHidden(true)

                // Status text
                Text(bikesMounted ? "bikes_status_mounted" : "bikes_status_not_mounted")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Toggle section
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
        }
        .onAppear {
            bikesMounted = BikeState.bikesMounted
        }
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
