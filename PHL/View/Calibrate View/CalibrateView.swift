//
//  CalibrateView.swift
//  PHL
//
//  Created by Tran Pat on 4/5/23.
//  Copyright © 2023 PAN Weiheng. All rights reserved.
//

import SwiftUI

struct CalibrateView: View {
    @EnvironmentObject var recorderCalibrate: RecorderCalibrate
    @State private var text: String = ""
    @State private var buttonText  = "Copy to clipboard"
    private let pasteboard = UIPasteboard.general
    
    init() {
        // Remove top empty space
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {
        
         NavigationView {
            
            Form {
                if recorderCalibrate.isCalibrating == false {
                    // clear array whenever it stops recording
                    let _ = recorderCalibrate.clearAccelerometerArray()
                    let _ = recorderCalibrate.clearGyroscopeArray()
                    
                } else {
                    
                    
                }
                
                HStack {
                    Text(recorderCalibrate.intensityStr)
                        .font(.custom("default", size: 24))
                        .fontWeight(.bold)
                        .frame(alignment: .center)
                    // MARK: Copy to clipboard Button
                    Spacer()
                    Button {
                        copyToClipboard()
                    } label: {
                        Label(buttonText, systemImage: "doc.on.doc.fill")
                    }
                    .tint(.orange)
                }
                
                // MARK: Start/Stop Button
                
                HStack {
                    Spacer()
                    
                    Toggle(isOn: $recorderCalibrate.isCalibrating.animation()) {
                        Text(recorderCalibrate.isCalibrating ? "Stop" : "Start")
                            .bold()
                            .animation(nil)
                    }
                    .buttonStyle(.plain)
                    .toggleStyle(CircularToggleStyle(sideLength: 60))
                    .padding(10)
                    
                    Spacer()
                }
            }
            .navigationBarTitle(recorderCalibrate.isCalibrating ? "Calibrating" : "Calibrate")
            .navigationBarItems(trailing:
                Button(self.recorderCalibrate.isCalibrating ? "Stop" : "") {
                    self.recorderCalibrate.isCalibrating = false
                    #if DEBUG
                    print("set")
                    #endif
            })
        }
    }
    
    func paste(){
        if let string = pasteboard.string {
            text = string
        }
    }
    
    func copyToClipboard() {
        pasteboard.string = self.text
        
        self.buttonText = "Copied!"
        self.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.buttonText = "Copy to clipboard"
        }
    }
}

struct CalibrateView_Previews: PreviewProvider {
    static let myEnvObject = RecorderCalibrate()
    static var previews: some View {
        CalibrateView()
            .environmentObject(myEnvObject)
        
        CalibrateView()
            .environmentObject(myEnvObject)
            .colorScheme(.dark)
    }
}
