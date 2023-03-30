import Combine
import SwiftUI
import Charts

struct RecorderView: View {
    
    @EnvironmentObject var recorderVibrate: RecorderVibrate
    var entry: MotionDataEntry { recorderVibrate.currentDataEntry }
        
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
                if recorderVibrate.isRecording == false {
                    
                    Section {
                        ItemRow(
                            nameView: HStack {
                                Image(systemName: "speedometer")
                                Text("Sampling Rate")
                            },
                            valueView: Text("\(Int(recorderVibrate.setting.samplingRate)) Hz"))
                        Slider(value: $recorderVibrate.setting.samplingRate, in: 1 ... 200, step: 1)
                    }
                    
                    // clear array whenever it stops recording
                    let _ = recorderVibrate.clearAccelerometerArray()
                    let _ = recorderVibrate.clearGyroscopeArray()
                    
                } else {
                    VStack {
                        if entry.accelerometerData != nil {
                            GroupBox("Accelerometer X") {
                                Chart {
                                    ForEach(Array(recorderVibrate.accelerometerDataX.enumerated()), id: \.element) { index, number in
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
                                    ForEach(Array(recorderVibrate.accelerometerDataY.enumerated()), id: \.element) { index, number in
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
                                    ForEach(Array(recorderVibrate.accelerometerDataZ.enumerated()), id: \.element) { index, number in
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
                                    ForEach(Array(recorderVibrate.gyroscopeDataX.enumerated()), id: \.element) { index, number in
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
                                    ForEach(Array(recorderVibrate.gyroscopeDataY.enumerated()), id: \.element) { index, number in
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
                                    ForEach(Array(recorderVibrate.gyroscopeDataZ.enumerated()), id: \.element) { index, number in
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
                    
                    Toggle(isOn: $recorderVibrate.isRecording.animation()) {
                        Text(recorderVibrate.isRecording ? "Stop" : "Start")
                            .bold()
                            .animation(nil)
                    }
                    .buttonStyle(.plain)
                    .toggleStyle(CircularToggleStyle(sideLength: 60))
                    .padding(10)
                    
                    Spacer()
                }
            }
            .navigationBarTitle(recorderVibrate.isRecording ? "Recording" : "Record")
            .navigationBarItems(trailing:
                Button(self.recorderVibrate.isRecording ? "Stop" : "") {
                    self.recorderVibrate.isRecording = false
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
                .environmentObject(RecorderVibrate())
            
            RecorderView()
                .environmentObject(RecorderVibrate())
                .colorScheme(.dark)
        }
    }
}
