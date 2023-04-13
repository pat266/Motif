import Foundation
import Combine
import CoreMotion // for accelerator and gyroscope
import CoreHaptics // for vibration
import AudioToolbox.AudioServices


class RecorderPressure: ObservableObject {
    
    internal struct RecordSetting {
        var samplingRate: Double = 200
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
    
    @Published var setting: RecorderPressure.RecordSetting = RecordSetting()
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
    
    // actual values (intensity, weight) - hard coded
    private let data: [(x: Double, y: Double)] =
        [
            (0.0005369690916273328, 0), // nothing
            (0.000390707736545139, 271), // iphone
            (0.0004271815617879224, 154), // pixel 5
            (0.000441518274943034, 38), // iphone nm case
            (0.0003724842495388455, 382) // speaker
        ]
    
    private let iphoneSE_data: [(x: Double, y: Double)] =
        [
            (0.0005038803948296405, 111),
            (0.00036225869920518996, 817),
            (0.0003869273503621398, 571),
            (0.00048243151770697724, 160),
            (0.0005736389160156272, 0)
        ]
    
    private let iphone13_data: [(x: Double, y: Double)] =
        [
            (0.0009183968438042532, 111),
            (0.0005593922932942707, 817),
            (0.0005666442871093751, 571),
            (0.0008060882568359371, 160),
            (0.0015439147949218677, 0)
        ]
    
    private let model: LinearRegression = LinearRegression()
    
    // MARK: - Initializer
    
    init() {
        // loadSampleListFromDisk()
        
        // fit the hard-coded data
        self.model.fit(data: self.data)
        print("Intercept: " + String(self.model.intercept))
        print("Slope: " + String(self.model.slope))
    }
    
    // MARK: - De-Initializer
    deinit {
        
    }

    // MARK: - Methods
    
    internal func startCalibrating() {
        guard manager.isDeviceAvailable == true else { return }
        
        self.intensityStr = "Starting in 3"
        
        // start vibrating
        vibrator.vibrateInSeconds(duration: 30)
        
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
                    self.intensityStr = ""
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
                     let intensity = String(self.getIntensity())
                    print("Intensity: " + intensity)
                    // self.intensityStr = "Intensity: " + intensity
                    let weight = self.model.predict(self.getIntensity())
                    self.intensityStr = "Predicted weight: " + String(weight)
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
