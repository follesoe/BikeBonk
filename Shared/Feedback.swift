//
//  Feedback.swift
//  BikeBonk
//
//  Provides haptic and audio feedback when toggling bike status.
//  Respects silent mode on all platforms.
//

#if os(iOS)
import UIKit
import AudioToolbox

/// Feedback manager for iOS - provides haptic and sound feedback.
enum Feedback {
    /// Play feedback for when bikes are marked as mounted (warning state).
    static func playMounted() {
        // Haptic: Warning notification
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)

        // Sound: System sound from Theme
        AudioServicesPlaySystemSound(Theme.Warning.soundID)
    }

    /// Play feedback for when bikes are marked as removed (safe state).
    static func playRemoved() {
        // Haptic: Success notification
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)

        // Sound: System sound from Theme
        AudioServicesPlaySystemSound(Theme.Safe.soundID)
    }

    /// Play feedback based on the new mounted state.
    static func play(forMountedState mounted: Bool) {
        if mounted {
            playMounted()
        } else {
            playRemoved()
        }
    }
}

#elseif os(watchOS)
import WatchKit

/// Feedback manager for watchOS - provides haptic and sound feedback.
enum Feedback {
    /// Play feedback for when bikes are marked as mounted (warning state).
    static func playMounted() {
        WKInterfaceDevice.current().play(.notification)
    }

    /// Play feedback for when bikes are marked as removed (safe state).
    static func playRemoved() {
        WKInterfaceDevice.current().play(.success)
    }

    /// Play feedback based on the new mounted state.
    static func play(forMountedState mounted: Bool) {
        if mounted {
            playMounted()
        } else {
            playRemoved()
        }
    }
}
#endif
