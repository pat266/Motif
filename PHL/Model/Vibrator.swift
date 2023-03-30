//
//  Vibrator.swift
//  PHL
//
//  Created by Tran Pat on 3/30/23.
//  Copyright © 2023 PAN Weiheng. All rights reserved.
//

import Foundation
import Combine
import CoreHaptics // for vibration


class Vibrator : ObservableObject {
    private var engine: CHHapticEngine?
    private var timerVibration: AnyCancellable? = nil // timer to renew vibration
    
    // MARK: - Initializer
    
    init() {
        self.initHaptic()
    }
    
    // MARK: - De-Initializer
    deinit {
        self.destroyHaptics()
    }
    
    // MARK: - Vibration Methods
    func initHaptic() {
        // check device support
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func startHaptics() {
        do {
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func stopHaptics() {
        engine?.stop()
        timerVibration?.cancel()
    }

    func destroyHaptics() {
        // The engine stopped; print out why
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = { [weak self] in
            print("The engine reset")

            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
    
    func playHaptic(event: CHHapticEvent) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func vibrateIndefinitely() {
        // start up the vibration
        self.startHaptics()
        // How strong the haptic is (0 - 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        // supposed to be infinite, but I think the max is 30 seconds
        let hapticCustom = CHHapticEvent(eventType: .hapticContinuous, parameters: [ sharpness], relativeTime: 0, duration: .infinity)
        self.playHaptic(event: hapticCustom)
        
        // Activate the vibration timer every second
        timerVibration = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                // Vibrate the device
                self.startHaptics()
                // How strong the haptic is (0 - 1)
                let sharpness = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                // supposed to be infinite, but I think the max is 30 seconds
                let hapticCustom = CHHapticEvent(eventType: .hapticContinuous, parameters: [ sharpness], relativeTime: 0, duration: .infinity)
                self.playHaptic(event: hapticCustom)
        }
    }

}
