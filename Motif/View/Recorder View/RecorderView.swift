//
//  RecorderView.swift
//  Motif
//
//  Created by Pan Weiheng on 2020/3/29.
//

import Combine
import SwiftUI

// https://github.com/AppPear/ChartView.git
// import SwiftUICharts

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
    
    private var maxData = 200
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
                    
                    // clear array whenever it stops recording
                    let _ = recorder.clearAccelerometerArray()
                    let _ = recorder.clearGyroscopeArray()
                    
                    
                } else {
                    VStack {
                        if entry.accelerometerData != nil {
//                            MultiLineChartView(data:
//                                                [
//                                                    (recorder.accelerometerDataX, GradientColors.green),
//                                                    (recorder.accelerometerDataY, GradientColors.purple),
//                                                    (recorder.accelerometerDataZ, GradientColors.orange)
//                                                ],
//                                               title: "Accelerometer Graph",
//                                               form: ChartForm.extraLarge
//                            ).padding()
                            
//                            LineChartView(data: recorder.accelerometerDataX,
//                                          title: "recorder.accelerometerDataX",
//                                          form: ChartForm.extraLarge,
//                                          dropShadow: true
//                            ).padding()
                        }
                    }
                    
                    HStack {
                        if entry.gyroData != nil {
//                            MultiLineChartView(data:
//                                                [
//                                                    (recorder.gyroscopeDataX, GradientColors.green),
//                                                    (recorder.gyroscopeDataY, GradientColors.purple),
//                                                    (recorder.gyroscopeDataZ, GradientColors.orange)
//                                                ],
//                                               title: "Gyroscope Graph",
//                                               form: ChartForm.extraLarge
//                            ).padding()
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
