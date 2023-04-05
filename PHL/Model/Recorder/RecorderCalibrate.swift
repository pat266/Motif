import Foundation
import Combine
import CoreMotion // for accelerator and gyroscope
import CoreHaptics // for vibration
import AudioToolbox.AudioServices


class RecorderCalibrate: ObservableObject {
    
    internal struct RecordSetting {
        var samplingRate: Double = 100
        var maxData: Int = 200
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let manager = CMMotionManager()
    private let vibrator = Vibrator()
    
    private let haveStarted: Bool = false // boolean for vibration check
    private var timerUpdate: AnyCancellable? = nil // timer to update data
    
    var samplingInterval: Double { 1.0 / setting.samplingRate }
    
    @Published var setting: RecorderCalibrate.RecordSetting = RecordSetting()
    @Published var isRecording: Bool = false {
        willSet {
            newValue ? startRecording() : stopRecording()
        }
    }
    
    @Published var accelerometerDataY: [Double] = []
    @Published var gyroscopeDataY: [Double] = []
    
    @Published var intensity: Double = 0
    
    
    private let sampleListFileName: String = "sampleList.json"
    private var sampleListFileURL: URL {
        FileManager.default.documentDirectoryURL(appending: sampleListFileName)
    }
    
    // MARK: - Initializer
    
    init() {
        // loadSampleListFromDisk()
    }
    
    // MARK: - De-Initializer
    deinit {
        
    }

    // MARK: - Methods
    
    internal func startRecording() {
        guard manager.isDeviceAvailable == true else { return }
        
        // start vibrating
        vibrator.vibrateIndefinitely()
        
        // Set sampling intervals
        manager.accelerometerUpdateInterval = samplingInterval
        manager.gyroUpdateInterval          = samplingInterval
        
        // Start data updates
        manager.startAccelerometerUpdates()
        manager.startGyroUpdates()
        
        // Activate timer
        timerUpdate = Timer.publish(every: samplingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                guard let accelerometerData = self.manager.accelerometerData,
                    let gyroData = self.manager.gyroData
                    else { return }
                
                self.updateData(accelerometerData:accelerometerData, gyroData:gyroData)

        }
        
    }
    
    internal func stopRecording() {
        
        guard manager.isDeviceAvailable == true else { return }
        
        // Invalidate timer
        timerUpdate?.cancel()
        
        // Stop data updates
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
        
        // cancel the vibration
        vibrator.stopHaptics()
    }
    
    private func updateData(accelerometerData: CMAccelerometerData, gyroData: CMGyroData) -> Void {
        // add accelerometer data to the array
        self.accelerometerDataY.append(accelerometerData.acceleration.y)
        
        // add gyroscope data to the array
        self.gyroscopeDataY.append(gyroData.rotationRate.y)
        
    }
    
    private func getIntensity() -> Double {
        return Pressure.calculateIntensity(y_accelerometer: self.accelerometerDataY)
    }
}

private extension CMMotionManager {
    
    var isDeviceAvailable: Bool {
        return isAccelerometerAvailable
            && isGyroAvailable
    }
}
