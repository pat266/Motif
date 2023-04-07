//
//  PressureView.swift
//  PHL
//
//  Created by Tran Pat on 4/7/23.
//  Copyright © 2023 PAN Weiheng. All rights reserved.
//

import SwiftUI

struct PressureView: View {
    @EnvironmentObject var recorderPressure: RecorderPressure
    
    init() {
        // Remove top empty space
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {
        
         NavigationView {
            
            Form {
                if recorderPressure.isCalibrating == false {
                    // clear array whenever it stops recording
                    let _ = recorderPressure.clearAccelerometerArray()
                    let _ = recorderPressure.clearGyroscopeArray()
                    
                } else {
                    
                    
                }
                
                HStack {
                    Text(recorderPressure.intensityStr)
                        .font(.custom("default", size: 24))
                        .fontWeight(.bold)
                        .frame(alignment: .center)
                }
                
                // MARK: Start/Stop Button
                
                HStack {
                    Spacer()
                    
                    Toggle(isOn: $recorderPressure.isCalibrating.animation()) {
                        Text(recorderPressure.isCalibrating ? "Stop" : "Start")
                            .bold()
                            .animation(nil)
                    }
                    .buttonStyle(.plain)
                    .toggleStyle(CircularToggleStyle(sideLength: 60))
                    .padding(10)
                    
                    Spacer()
                }
            }
            .navigationBarTitle(recorderPressure.isCalibrating ? "Weighing" : "Weigh")
            .navigationBarItems(trailing:
                Button(self.recorderPressure.isCalibrating ? "Stop" : "") {
                    self.recorderPressure.isCalibrating = false
                    #if DEBUG
                    print("set")
                    #endif
            })
        }
    }
}

struct PressureView_Previews: PreviewProvider {
    static let myEnvObject = RecorderPressure()
    static var previews: some View {
        PressureView()
            .environmentObject(myEnvObject)
        
        PressureView()
            .environmentObject(myEnvObject)
            .colorScheme(.dark)
    }
}
