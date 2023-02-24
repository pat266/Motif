//
//  RecorderView.swift
//  Motif
//
//  Created by Pan Weiheng on 2020/3/29.
//

import Combine
import SwiftUI

// https://github.com/AppPear/ChartView.git
import SwiftUICharts

struct RecorderView: View {
    
    @EnvironmentObject var recorder: Recorder
    var entry: MotionDataEntry { recorder.currentDataEntry }
        
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss.SSSS"
        return formatter
    }()
    
    init() {
        // Remove top empty space
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    let queue = OperationQueue()
    //let manager = CMMotionManager()
    
    @State var timerSubscription: Timer?
    
    @State var accelerometerDataX: [Double] = []
    @State var accelerometerDataY: [Double] = []
    @State var accelerometerDataZ: [Double] = []
    
    var body: some View {
        
        
         NavigationView {
            
            Form {
                if recorder.isRecording == false {
                    
                    Section {
                        ItemRow(
                            nameView: HStack {
                                Image(systemName: "speedometer")
                                Text("Sampling Rate")
                            },
                            valueView: Text("\(Int(recorder.setting.samplingRate)) Hz"))
                        Slider(value: $recorder.setting.samplingRate, in: 1 ... 200, step: 1)
                    }
                    
                    let _ = timerSubscription?.invalidate()
                    if (!accelerometerDataX.isEmpty) {
                        let _ = accelerometerDataX.removeAll()
                    }
                    if (!accelerometerDataY.isEmpty) {
                        let _ = accelerometerDataY.removeAll()
                    }
                    if (!accelerometerDataZ.isEmpty) {
                        let _ = accelerometerDataZ.removeAll()
                    }
                    
                    
                } else {
                    
                    if entry.accelerometerData != nil {
                        Section(header: Text("Acceleration").font(.subheadline).bold()) {
                            ItemRow(name: "timestamp", value: dateFormatter.string(from: entry.accelerometerData.timestamp))
                            ItemRow(name: "x", value: "\(entry.accelerometerData.acceleration.x) G")
                            ItemRow(name: "y", value: "\(entry.accelerometerData.acceleration.y) G")
                            ItemRow(name: "z", value: "\(entry.accelerometerData.acceleration.z) G")
                            Spacer()
                            MultiLineChartView(data:
                                                [
                                                    (accelerometerDataX, GradientColors.green),
                                                     (accelerometerDataY, GradientColors.purple),
                                                     (accelerometerDataZ, GradientColors.orange)
                                                ],
                                               title: "Accelerometer Graph",
                                               form: ChartForm.extraLarge,
                                               dropShadow: false)
                        }
                        .onAppear {
                            // Activate timer
                            timerSubscription = Timer.scheduledTimer(withTimeInterval: (1.0 / recorder.setting.samplingRate), repeats: true) { _ in
                                accelerometerDataX.append(entry.accelerometerData.acceleration.x)
                                accelerometerDataY.append(entry.accelerometerData.acceleration.y)
                                accelerometerDataZ.append(entry.accelerometerData.acceleration.z)
                            }
                            
                        }
                    }
                    
                    if entry.gyroData != nil {
                        Section(header: Text("Gyroscope").font(.subheadline).bold()) {
                            ItemRow(name: "timestamp", value: dateFormatter.string(from: entry.gyroData.timestamp))
                            ItemRow(name: "x", value: "\(entry.gyroData.rotationRate.x) rad/s")
                            ItemRow(name: "y", value: "\(entry.gyroData.rotationRate.y) rad/s")
                            ItemRow(name: "z", value: "\(entry.gyroData.rotationRate.z) rad/s")
                        }
                    }
                    
                }
                
                // MARK: Start/Stop Button
                
                HStack {
                    Spacer()
                    
                    Toggle(isOn: $recorder.isRecording.animation()) {
                        Text(recorder.isRecording ? "Stop" : "Start")
                            .bold()
                            .animation(nil)
                    }
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

struct CircularToggleStyle: ToggleStyle {
    var sideLength: CGFloat
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: sideLength, height: sideLength)
            .padding()
            .foregroundColor(.white)
            .background(configuration.isOn ? Color.red : Color.accentColor)
            .cornerRadius(sideLength)
            .onTapGesture {
                configuration.$isOn.wrappedValue.toggle()
        }
    }
}

struct RecorderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecorderView()
                .environmentObject(Recorder())
            
            RecorderView()
                .environmentObject(Recorder())
                .colorScheme(.dark)
        }
    }
}