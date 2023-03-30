//
//  AngleView.swift
//  PHL
//
//  Created by Tran Pat on 3/29/23.
//  Copyright © 2023 PAN Weiheng. All rights reserved.
//

import Combine
import SwiftUI
import Charts

struct AngleView: View {
    
    @EnvironmentObject var recorder: Recorder
    
    init() {
        // Remove top empty space
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {
        
         NavigationView {
            
            Form {
                if recorder.isRecording == false {
                    // clear array whenever it stops recording
                    let _ = recorder.clearAccelerometerArray()
                    let _ = recorder.clearGyroscopeArray()
                    
                } else {
                    Text(String(format: "%.0f", recorder.angle_degree)).padding() // angle
                }
                
                // MARK: Start/Stop Button
                
                HStack {
                    Spacer()
                    
                    Toggle(isOn: $recorder.isRecording.animation()) {
                        Text(recorder.isRecording ? "Stop" : "Start")
                            .bold()
                            .animation(nil)
                    }
                    .buttonStyle(.plain)
                    .toggleStyle(CircularToggleStyle(sideLength: 60))
                    .padding(10)
                    
                    Spacer()
                }
            }
            .navigationBarTitle(recorder.isRecording ? "Recording" : "Record")
            .navigationBarItems(trailing:
                Button(self.recorder.isRecording ? "Stop" : "") {
                    self.recorder.isRecording = false
                    #if DEBUG
                    print("set")
                    #endif
            })
        }
    }
}

struct AngleView_Previews: PreviewProvider {
    static let myEnvObject = Recorder()
    static var previews: some View {
        AngleView()
            .environmentObject(myEnvObject)
        
        AngleView()
            .environmentObject(myEnvObject)
            .colorScheme(.dark)
    }
}
