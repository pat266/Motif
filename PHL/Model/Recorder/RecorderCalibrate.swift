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
    private var timerCountDown: AnyCancellable? = nil // timer to count down before calibrate
    private var timerVibrate: AnyCancellable? = nil // timer to calibrate
    
    var samplingInterval: Double { 1.0 / setting.samplingRate }
    
    @Published var setting: RecorderCalibrate.RecordSetting = RecordSetting()
    @Published var isCalibrating: Bool = false {
        willSet {
            newValue ? startCalibrating() : stopCalibrating()
        }
    }
    
    @Published var accelerometerDataY: [Double] = []
    @Published var gyroscopeDataY: [Double] = []
    
    @Published var intensityStr: String = ""
    
    
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
    
    internal func startCalibrating() {
        guard manager.isDeviceAvailable == true else { return }
        
        self.intensityStr = "Starting in 3"
        
        // start vibrating
        vibrator.vibrateIndefinitely()
        
        // Set sampling intervals
        manager.accelerometerUpdateInterval = samplingInterval
        manager.gyroUpdateInterval          = samplingInterval
        
        // Start data updates
        manager.startAccelerometerUpdates()
        manager.startGyroUpdates()
         
        self.startCountingDownTimer()
        
    }
    
    private func startCountingDownTimer() {
        // activate timer for counting down
        var elapsedSeconds = 0
        timerCountDown = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                elapsedSeconds += 1
                if elapsedSeconds > 3 {
                    self.intensityStr = "Remaining time: 5"
                    self.startMeasuringTimer()
                    self.timerCountDown?.cancel()
                } else {
                    self.intensityStr = "Starting in " + String(3 - elapsedSeconds)
                }
            
        }
    }
    
    private func startMeasuringTimer() {
        // Activate timer
        timerUpdate = Timer.publish(every: samplingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                guard let accelerometerData = self.manager.accelerometerData,
                    let gyroData = self.manager.gyroData
                    else { return }
                
                self.updateData(accelerometerData:accelerometerData, gyroData:gyroData)

        }
        
        // activate timer for calibration
        var elapsedSeconds = 0
        timerVibrate = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                elapsedSeconds += 1
                if elapsedSeconds > 5 {
                    // let intensity = String(format: "%.10f", self.getIntensity())
                    let intensity = String(self.getIntensity())
                    self.intensityStr = "Intensity: " + intensity
                    print("Intensity: " + intensity)
                    self.isCalibrating = false
                    self.timerVibrate?.cancel()
                } else {
                    self.intensityStr = "Remaining time: " + String(5 - elapsedSeconds)
                }
            
        }
    }
    
    
    
    internal func stopCalibrating() {
        
        guard manager.isDeviceAvailable == true else { return }
        
        // Invalidate timer
        self.timerUpdate?.cancel()
        self.timerVibrate?.cancel()
        self.timerCountDown?.cancel()
        
        // Stop data updates
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
        
        self.clearAccelerometerArray()
        self.clearGyroscopeArray()
        
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
    
    // MARK: - Clear the data
    
    public func clearAccelerometerArray() {
        if (!accelerometerDataY.isEmpty) {
            self.accelerometerDataY.removeAll()
        }
    }
    
    public func clearGyroscopeArray() {
        if (!gyroscopeDataY.isEmpty) {
            self.gyroscopeDataY.removeAll()
        }
    }
}

private extension CMMotionManager {
    
    var isDeviceAvailable: Bool {
        return isAccelerometerAvailable
            && isGyroAvailable
    }
}
