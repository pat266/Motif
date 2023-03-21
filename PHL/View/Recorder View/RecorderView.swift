import Combine
import SwiftUI
import Charts

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
    
    private var maxData: Int = 200
    
    @State var timerSubscription: Timer?
    
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
                            GroupBox("Accelerometer X") {
                                Chart {
                                    ForEach(Array(recorder.accelerometerDataX.enumerated()), id: \.element) { index, number in
                                        LineMark(
                                            x: .value("index", index),
                                            y: .value("value", number)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .chartXAxis(.hidden)
                                .padding(.horizontal)
                            }
                            
                            GroupBox("Accelerometer Y") {
                                Chart {
                                    ForEach(Array(recorder.accelerometerDataY.enumerated()), id: \.element) { index, number in
                                        LineMark(
                                            x: .value("index", index),
                                            y: .value("value", number)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .chartXAxis(.hidden)
                                .padding(.horizontal)
                            }
                            
                            GroupBox("Accelerometer Z") {
                                Chart {
                                    ForEach(Array(recorder.accelerometerDataZ.enumerated()), id: \.element) { index, number in
                                        LineMark(
                                            x: .value("index", index),
                                            y: .value("value", number)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .chartXAxis(.hidden)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer()
                    VStack {
                        if entry.gyroData != nil {
                            GroupBox("Gyroscope X") {
                                Chart {
                                    ForEach(Array(recorder.gyroscopeDataX.enumerated()), id: \.element) { index, number in
                                        LineMark(
                                            x: .value("index", index),
                                            y: .value("value", number)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .chartXAxis(.hidden)
                                .padding(.horizontal)
                            }
                            
                            GroupBox("Gyroscope Y") {
                                Chart {
                                    ForEach(Array(recorder.gyroscopeDataY.enumerated()), id: \.element) { index, number in
                                        LineMark(
                                            x: .value("index", index),
                                            y: .value("value", number)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .chartXAxis(.hidden)
                                .padding(.horizontal)
                            }
                            
                            GroupBox("gyroscope Z") {
                                Chart {
                                    ForEach(Array(recorder.gyroscopeDataZ.enumerated()), id: \.element) { index, number in
                                        LineMark(
                                            x: .value("index", index),
                                            y: .value("value", number)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .chartXAxis(.hidden)
                                .padding(.horizontal)
                            }
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
