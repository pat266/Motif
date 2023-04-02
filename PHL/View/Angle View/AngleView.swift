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
    
    @EnvironmentObject var recorderAngle: RecorderAngle
    
    init() {
        // Remove top empty space
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {
        
         NavigationView {
            
            Form {
                if recorderAngle.isRecording == false {
                    // clear array whenever it stops recording
//                    let _ = recorderAngle.clearAccelerometerArray()
//                    let _ = recorderAngle.clearGyroscopeArray()
                    
                } else {
                    HStack {
                        Text(String(format: "%.0f", recorderAngle.angle_degree))
                            .font(.custom("default", size: 48))
                            .fontWeight(.bold)
                            .frame(alignment: .center)// angle
                    }
                    
                }
                
                // MARK: Start/Stop Button
                
                HStack {
                    Spacer()
                    
                    Toggle(isOn: $recorderAngle.isRecording.animation()) {
                        Text(recorderAngle.isRecording ? "Stop" : "Start")
                            .bold()
                            .animation(nil)
                    }
                    .buttonStyle(.plain)
                    .toggleStyle(CircularToggleStyle(sideLength: 60))
                    .padding(10)
                    
                    Spacer()
                }
            }
            .navigationBarTitle(recorderAngle.isRecording ? "Recording" : "Record")
            .navigationBarItems(trailing:
                Button(self.recorderAngle.isRecording ? "Stop" : "") {
                    self.recorderAngle.isRecording = false
                    #if DEBUG
                    print("set")
                    #endif
            })
        }
    }
}

struct AngleView_Previews: PreviewProvider {
    static let myEnvObject = RecorderAngle()
    static var previews: some View {
        AngleView()
            .environmentObject(myEnvObject)
        
        AngleView()
            .environmentObject(myEnvObject)
            .colorScheme(.dark)
    }
}
