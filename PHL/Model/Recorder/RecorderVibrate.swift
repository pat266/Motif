//
//  RecorderVibrate.swift
//  PHL
//
//  Created by Tran Pat on 3/30/23.
//  Copyright © 2023 PAN Weiheng. All rights reserved.
//

import Foundation

class RecorderVibrate : Recorder {
    private let vibrator = Vibrator()
    
    private func startRecordingAndVibrate() {
        // start vibrating
        vibrator.vibrateIndefinitely()
        
        super.startRecording()
    }
    
    private func stopRecordingAndVibrate() {
        // cancel the vibration
        vibrator.stopHaptics()
        
        super.stopRecording()
    }
}
